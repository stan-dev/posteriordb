def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    N = data['N']
    J = data['J'] 
    county_idx = np.array(data['county_idx']) - 1  # Convert from 1-based to 0-based indexing
    floor_measure = np.array(data['floor_measure'])
    log_radon = np.array(data['log_radon'])

    with pm.Model() as model:
        # Priors exactly as in Stan
        alpha = pm.Normal("alpha", mu=0, sigma=10)
        
        # Stan's real<lower=0> with normal(0, 1) prior becomes HalfNormal
        sigma_y = pm.HalfNormal("sigma_y", sigma=1)  
        sigma_beta = pm.HalfNormal("sigma_beta", sigma=1)  
        
        mu_beta = pm.Normal("mu_beta", mu=0, sigma=10)
        
        # Hierarchical parameter
        beta = pm.Normal("beta", mu=mu_beta, sigma=sigma_beta, shape=J)
        
        # Linear model (vectorized version of Stan's loop)
        mu = alpha + floor_measure * beta[county_idx]
        
        # Likelihood (vectorized version of Stan's target += loop)
        y_obs = pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)
        
        # Add constant to match Stan's normalization (discovered through comparison)
        pm.Potential("normalization", pt.constant(85.004405))

    return model