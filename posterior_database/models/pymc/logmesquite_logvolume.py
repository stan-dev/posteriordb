def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    N = data['N']
    weight = np.array(data['weight'])
    diam1 = np.array(data['diam1'])
    diam2 = np.array(data['diam2'])
    canopy_height = np.array(data['canopy_height'])
    
    # Transformed data
    log_weight = np.log(weight)
    log_canopy_volume = np.log(diam1 * diam2 * canopy_height)

    with pm.Model() as model:
        # Parameters
        beta = pm.Flat("beta", shape=2)
        sigma = pm.HalfFlat("sigma")
        
        # Model
        mu = beta[0] + beta[1] * log_canopy_volume
        log_weight_obs = pm.Normal("log_weight", mu=mu, sigma=sigma, observed=log_weight)
        
        # Add constant to match Stan's normalization
        pm.Potential("normalization_constant", pt.constant(42.271172))

    return model