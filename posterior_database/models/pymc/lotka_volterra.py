def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    from pymc.ode import DifferentialEquation
    
    N = data['N']
    ts = data['ts']
    y_init = data['y_init']
    y = data['y']
    
    with pm.Model() as model:
        # Parameters
        theta = pm.HalfFlat("theta", shape=4)
        z_init = pm.HalfFlat("z_init", shape=2)  
        sigma = pm.HalfFlat("sigma", shape=2)
        
        # Priors using Potentials
        pm.Potential("theta_13_prior", pm.logp(pm.Normal.dist(mu=1, sigma=0.5), theta[[0, 2]]).sum())
        pm.Potential("theta_24_prior", pm.logp(pm.Normal.dist(mu=0.05, sigma=0.05), theta[[1, 3]]).sum())
        pm.Potential("sigma_prior", pm.logp(pm.LogNormal.dist(mu=-1, sigma=1), sigma).sum())
        pm.Potential("z_init_prior", pm.logp(pm.LogNormal.dist(mu=pt.log(10), sigma=1), z_init).sum())
        
        # Define ODE system
        def dz_dt(z, t, p):
            u, v = z[0], z[1]
            alpha, beta, gamma, delta = p[0], p[1], p[2], p[3]
            
            du_dt = (alpha - beta * v) * u
            dv_dt = (-gamma + delta * u) * v
            return [du_dt, dv_dt]
        
        # Solve ODE
        ode_solution = DifferentialEquation(
            func=dz_dt, 
            times=ts, 
            n_states=2, 
            n_theta=4,
            t0=0
        )
        
        z = ode_solution(y0=z_init, theta=theta)
        
        # Likelihood for initial observations
        pm.Potential("y_init_like", pm.logp(pm.LogNormal.dist(mu=pt.log(z_init), sigma=sigma), y_init).sum())
        
        # Likelihood for time series observations
        pm.Potential("y_like", pm.logp(pm.LogNormal.dist(mu=pt.log(z), sigma=sigma[None, :]), y).sum())
    
    return model