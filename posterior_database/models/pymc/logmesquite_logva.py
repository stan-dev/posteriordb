def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    weight = np.array(data['weight'])
    diam1 = np.array(data['diam1'])
    diam2 = np.array(data['diam2'])
    canopy_height = np.array(data['canopy_height'])
    group = np.array(data['group'])

    # Transformed data
    log_weight = np.log(weight)
    log_canopy_volume = np.log(diam1 * diam2 * canopy_height)
    log_canopy_area = np.log(diam1 * diam2)

    with pm.Model() as model:
        # Parameters
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfFlat("sigma")
        
        # Model
        mu = beta[0] + beta[1] * log_canopy_volume + beta[2] * log_canopy_area + beta[3] * group
        
        # Use a custom potential to match Stan's propto form
        # Stan's log likelihood (proportional): -0.5 * sum((y - mu)^2 / sigma^2) - N * log(sigma)
        N = len(log_weight)
        residuals = log_weight - mu
        log_lik = -0.5 * pt.sum((residuals**2) / (sigma**2)) - N * pt.log(sigma)
        pm.Potential("likelihood", log_lik)

    return model