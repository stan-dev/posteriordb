import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        J = data['J']
        y_obs = data['y']
        sigma_data = data['sigma']
        
        mu = pm.Normal("mu", mu=0, sigma=5)
        tau = pm.HalfCauchy("tau", beta=5)
        theta = pm.Normal("theta", mu=mu, sigma=tau, shape=J)
        
        if not prior_only:
            y = pm.Normal("y", mu=theta, sigma=sigma_data, observed=y_obs)
        
    return model