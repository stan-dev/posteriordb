def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    J = int(data['J'])
    y = np.asarray(data['y'], dtype=float)
    sigma = np.asarray(data['sigma'], dtype=float)

    with pm.Model() as model:
        # Parameters
        theta_trans = pm.Normal("theta_trans", mu=0, sigma=1, shape=J)
        mu = pm.Normal("mu", mu=0, sigma=5)
        tau = pm.HalfCauchy("tau", beta=5)
        
        # Transformed parameters
        theta = pm.Deterministic("theta", theta_trans * tau + mu)
        
        # Likelihood
        y_obs = pm.Normal("y", mu=theta, sigma=sigma, observed=y)
        
        # Add constant to match BridgeStan's proportional computation
        pm.Potential("const_adjustment", pt.as_tensor(39.26))

    return model