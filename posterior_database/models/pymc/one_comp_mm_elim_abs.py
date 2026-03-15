def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    from scipy.integrate import solve_ivp
    
    # Extract data
    t0 = data['t0']
    D = data['D'] 
    V = data['V']
    N_t = data['N_t']
    times = data['times']
    C_hat = data['C_hat']
    
    # Transformed data (hardcoded as in Stan model)
    C0 = np.array([0.0])
    x_r = np.array([D, V])
    
    def one_comp_mm_elim_abs(t, y, theta):
        """ODE function for one compartment MM elimination with absorption"""
        k_a, K_m, V_m = theta
        D_val, V_val = x_r
        
        dose = 0.0
        if t > 0:
            dose = np.exp(-k_a * t) * D_val * k_a / V_val
        
        elim = (V_m / V_val) * y[0] / (K_m + y[0])
        
        return np.array([dose - elim])
    
    def solve_ode(theta_vals):
        """Solve the ODE system"""
        def ode_func(t, y):
            return one_comp_mm_elim_abs(t, y, theta_vals)
        
        # Solve ODE from t0 to final time
        t_eval = np.concatenate([[t0], times])
        sol = solve_ivp(ode_func, [t0, times[-1]], C0, t_eval=t_eval, 
                       method='BDF', rtol=1e-6, atol=1e-8)
        
        # Return concentrations at measurement times (skip t0)
        return sol.y[0, 1:]  # Shape: (N_t,)
    
    with pm.Model() as model:
        # Priors - using HalfCauchy for positive parameters
        k_a = pm.HalfCauchy("k_a", beta=1)
        K_m = pm.HalfCauchy("K_m", beta=1) 
        V_m = pm.HalfCauchy("V_m", beta=1)
        sigma = pm.HalfCauchy("sigma", beta=1)
        
        # Stack parameters for ODE solver
        theta = pt.stack([k_a, K_m, V_m])
        
        # Solve ODE - use pm.ode for symbolic computation
        # Since PyMC doesn't have direct ODE integration, we'll use a custom op
        from pytensor.graph.op import Op
        from pytensor.graph.basic import Apply
        from pytensor.tensor.type import TensorType
        
        class ODESolveOp(Op):
            def make_node(self, theta):
                theta = pt.as_tensor_variable(theta)
                output_type = TensorType(dtype='float64', shape=(N_t,))
                return Apply(self, [theta], [output_type()])
            
            def perform(self, node, inputs, outputs):
                theta_vals = inputs[0]
                result = solve_ode(theta_vals)
                outputs[0][0] = result
        
        ode_solve_op = ODESolveOp()
        C_pred = ode_solve_op(theta)
        
        # Likelihood - lognormal with log link
        log_C_pred = pt.log(C_pred)
        
        # Observed concentrations
        C_obs = pm.LogNormal("C_obs", mu=log_C_pred, sigma=sigma, observed=C_hat)
        
    
    return model