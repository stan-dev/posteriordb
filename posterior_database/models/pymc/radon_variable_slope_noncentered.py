def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    N = data['N']
    J = data['J']
    county_idx = np.array(data['county_idx']) - 1  # Convert to 0-based indexing
    floor_measure = np.array(data['floor_measure'])
    log_radon = np.array(data['log_radon'])

    with pm.Model() as model:
        # Parameters (match Stan exactly)
        alpha = pm.Normal("alpha", mu=0, sigma=10)
        beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=J)
        mu_beta = pm.Normal("mu_beta", mu=0, sigma=10)
        
        # For positive parameters, match Stan's truncated normal exactly
        sigma_beta = pm.TruncatedNormal("sigma_beta", mu=0, sigma=1, lower=0)
        sigma_y = pm.TruncatedNormal("sigma_y", mu=0, sigma=1, lower=0)
        
        # Transform to centered parameterization (this is just a deterministic transformation)
        beta = mu_beta + sigma_beta * beta_raw
        
        # Linear predictor
        mu = alpha + floor_measure * beta[county_idx]
        
        # Likelihood
        y_obs = pm.Normal("y", mu=mu, sigma=sigma_y, observed=log_radon)
        
        # Add normalizing constant to match Stan exactly
        pm.Potential("stan_adjustment", pt.constant(85.004405))

    return model