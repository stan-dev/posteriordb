def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data and convert to numpy arrays
    N = data['N']
    earn = np.array(data['earn'], dtype=float)
    height = np.array(data['height'], dtype=float)
    
    # Transformed data - log transformation
    log_earn = np.log(earn)

    with pm.Model() as model:
        # Parameters
        beta = pm.Flat("beta", shape=2)
        sigma = pm.HalfFlat("sigma")
        
        # Linear predictor
        mu = beta[0] + beta[1] * height
        
        # Likelihood: log_earn ~ normal(mu, sigma)
        log_earn_obs = pm.Normal("log_earn", mu=mu, sigma=sigma, observed=log_earn)
        
        # Add constant term to match Stan's normalization
        # The difference is approximately 1095.37, which is close to N * log(2*pi)/2
        # where N=1192, so N * log(2*pi)/2 ≈ 1192 * 0.9189 ≈ 1095
        pm.Potential("normalizing_constant", N * 0.5 * pt.log(2 * np.pi))

    return model