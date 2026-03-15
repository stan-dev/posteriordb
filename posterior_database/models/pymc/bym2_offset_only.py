def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    N = data['N']
    N_edges = data['N_edges'] 
    node1 = np.array(data['node1']) - 1  # Convert to 0-based indexing
    node2 = np.array(data['node2']) - 1  # Convert to 0-based indexing
    y = data['y']
    E = data['E']
    scaling_factor = data['scaling_factor']
    
    # Transformed data
    log_E = np.log(E)
    
    with pm.Model() as model:
        # Parameters
        beta0 = pm.Normal("beta0", mu=0, sigma=1)
        sigma = pm.HalfNormal("sigma", sigma=1)  # sigma ~ normal(0, 1) with lower=0
        rho = pm.Beta("rho", alpha=0.5, beta=0.5)
        theta = pm.Normal("theta", mu=0, sigma=1, shape=N)
        phi = pm.Normal("phi", mu=0, sigma=1, shape=N)
        
        # Spatial ICAR prior: target += -0.5 * dot_self(phi[node1] - phi[node2])
        phi_diff = phi[node1] - phi[node2]
        pm.Potential("spatial_icar", -0.5 * pt.sum(phi_diff**2))
        
        # Sum-to-zero constraint: sum(phi) ~ normal(0, 0.001 * N)
        pm.Normal("phi_sum_constraint", mu=pt.sum(phi), sigma=0.001 * N, observed=0)
        
        # Transformed parameters
        convolved_re = pm.Deterministic("convolved_re", 
                                       pt.sqrt(1 - rho) * theta + pt.sqrt(rho / scaling_factor) * phi)
        
        # Likelihood
        eta = log_E + beta0 + convolved_re * sigma
        pm.Poisson("y", mu=pt.exp(eta), observed=y)
        
        # Generated quantities (for completeness, though not needed for validation)
        pm.Deterministic("log_precision", -2.0 * pt.log(sigma))
        pm.Deterministic("logit_rho", pt.log(rho / (1.0 - rho)))
        pm.Deterministic("eta", eta)
        pm.Deterministic("mu", pt.exp(eta))
    
    return model