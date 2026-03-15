def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    n = data['n']
    y = data['y']
    x = data['x'] 
    w = data['w']
    
    # Compute bounds for mu based on data statistics
    y_mean = np.mean(y)
    y_sd = np.std(y)  # ddof=0 like Stan's sd()
    mu_lower = y_mean - 3 * y_sd
    mu_upper = y_mean + 3 * y_sd
    
    # Precompute numpy index array for seasonal constraints
    t_indices = np.arange(11, n)

    with pm.Model() as model:
        # Parameters with explicit priors where needed
        # mu with bounds - implicit flat priors in Stan for unconstrained parts
        mu = pm.Uniform("mu", lower=mu_lower, upper=mu_upper, shape=n)

        # seasonal components - implicit flat priors in Stan
        seasonal = pm.Flat("seasonal", shape=n)

        # Regression coefficients - implicit flat priors in Stan
        beta = pm.Flat("beta")
        lambda_ = pm.Flat("lambda")

        # For positive_ordered, use a different approach
        # Start with unconstrained variables for the ordered part
        sigma_raw = pm.Normal("sigma_raw", mu=0, sigma=1, shape=3)

        # Transform to get positive ordered values
        # sigma[0] = exp(sigma_raw[0])
        # sigma[1] = sigma[0] + exp(sigma_raw[1])
        # sigma[2] = sigma[1] + exp(sigma_raw[2])
        sigma_0 = pt.exp(sigma_raw[0])
        sigma_1 = sigma_0 + pt.exp(sigma_raw[1])
        sigma_2 = sigma_1 + pt.exp(sigma_raw[2])
        sigma = pt.stack([sigma_0, sigma_1, sigma_2])
        sigma = pm.Deterministic("sigma", sigma)

        # Add prior for sigma ~ student_t(4, 0, 1) (vectorized)
        pm.Potential("sigma_prior", pt.sum(pm.logp(pm.StudentT.dist(nu=4, mu=0, sigma=1), sigma)))

        # Seasonal constraints (vectorized): for t >= 11 (0-based), seasonal[t] ~ normal(-sum(seasonal[t-11:t]), sigma[0])
        # This is equivalent to: sum(seasonal[t-11:t+1]) ~ Normal(0, sigma[0]) for each t in [11, n)
        # Use cumsum with zero-padding to compute rolling 12-element window sums
        cs = pt.cumsum(seasonal)
        cs_padded = pt.concatenate([pt.zeros(1), cs])  # prepend 0 so cs_padded[0] = 0
        # sum(seasonal[a:b]) = cs_padded[b] - cs_padded[a]
        # sum(seasonal[t-11:t+1]) = cs_padded[t+1] - cs_padded[t-11]
        window_sums = cs_padded[t_indices + 1] - cs_padded[t_indices - 11]
        pm.Potential("seasonal_constraint", pt.sum(pm.logp(pm.Normal.dist(mu=0, sigma=sigma[0]), window_sums)))

        # Random walk for mu (vectorized): mu[t] ~ normal(mu[t-1], sigma[1])
        mu_diff = mu[1:] - mu[:-1]
        pm.Potential("mu_rw", pt.sum(pm.logp(pm.Normal.dist(mu=0, sigma=sigma[1]), mu_diff)))
        
        # Transformed parameter
        yhat = mu + beta * x + lambda_ * w
        
        # Likelihood
        y_obs = pm.Normal("y", mu=yhat + seasonal, sigma=sigma[2], observed=y)
        
    return model