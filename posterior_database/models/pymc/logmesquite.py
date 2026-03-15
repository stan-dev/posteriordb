def make_model(data: dict) -> "pm.Model":
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Transformed data - compute log transformations
    log_weight = np.log(data['weight'])
    log_diam1 = np.log(data['diam1']) 
    log_diam2 = np.log(data['diam2'])
    log_canopy_height = np.log(data['canopy_height'])
    log_total_height = np.log(data['total_height'])
    log_density = np.log(data['density'])
    
    N = data['N']
    
    with pm.Model() as model:
        # Parameters
        # Stan: vector[7] beta; (no explicit prior = improper uniform)
        beta = pm.Flat("beta", shape=7)
        
        # Stan: real<lower=0> sigma; (no explicit prior, constrained positive = improper uniform on (0,∞))
        sigma = pm.HalfFlat("sigma")
        
        # Linear predictor - Stan uses 1-based indexing: beta[1] to beta[7]
        # Python uses 0-based indexing: beta[0] to beta[6] 
        mu = (beta[0] + beta[1] * log_diam1 + beta[2] * log_diam2 + 
              beta[3] * log_canopy_height + beta[4] * log_total_height + 
              beta[5] * log_density + beta[6] * data['group'])
        
        # Likelihood
        log_weight_obs = pm.Normal("log_weight", mu=mu, sigma=sigma, observed=log_weight)
        
        # Adjust for normalization constant difference between Stan and PyMC
        # Stan uses proportional likelihood, PyMC includes full normalization
        pm.Potential("normalization_adjustment", N * 0.5 * pt.log(2 * np.pi))
    
    return model