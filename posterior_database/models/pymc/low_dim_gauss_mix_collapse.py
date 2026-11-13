import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        y = data['y']
        
        mu = pm.Normal("mu", mu=0, sigma=2, shape=2)
        sigma = pm.HalfNormal("sigma", sigma=2, shape=2)
        theta = pm.Beta("theta", alpha=5, beta=5)

        w = pt.stack([theta, 1 - theta])

        if not prior_only:
            pm.NormalMixture("y", w=w, mu=mu, sigma=sigma, observed=y)

    return model