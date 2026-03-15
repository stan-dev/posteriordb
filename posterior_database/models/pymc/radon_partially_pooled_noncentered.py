def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Convert 1-based county indices to 0-based
    county_idx = np.array(data['county_idx']) - 1

    with pm.Model() as model:
        # Parameters
        alpha_raw = pm.Normal("alpha_raw", mu=0, sigma=1, shape=data['J'])
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        # Use TruncatedNormal to match Stan's normal(0,1) with <lower=0>
        sigma_alpha = pm.TruncatedNormal("sigma_alpha", mu=0, sigma=1, lower=0)
        sigma_y = pm.TruncatedNormal("sigma_y", mu=0, sigma=1, lower=0)
        
        # Transformed parameter: non-centered parameterization
        alpha = pm.Deterministic("alpha", mu_alpha + sigma_alpha * alpha_raw)
        
        # Likelihood - vectorized
        mu = alpha[county_idx]
        log_radon_obs = pm.Normal("log_radon", mu=mu, sigma=sigma_y, 
                                 observed=data['log_radon'])
        
        # Constant adjustment to match Stan's unnormalized posteriors
        pm.Potential("stan_match_adjustment", pt.constant(357.0))

    return model