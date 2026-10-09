import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    encouraged = np.array(data['encouraged'])
    watched_data = np.array(data['watched'], dtype=float)

    with pm.Model() as model:
        beta = pm.Flat("beta", shape=2)
        sigma = pm.HalfFlat("sigma")

        mu = pm.Deterministic("mu", beta[0] + beta[1] * encouraged)
        
        if not prior_only:
            pm.Normal("watched", mu=mu, sigma=sigma, observed=watched_data)

    return model