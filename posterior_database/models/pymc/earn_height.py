import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        earn = data['earn']
        height = data['height']
        
        beta = pm.Flat("beta", shape=2)
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * height)
        
        if not prior_only:
            pm.Normal("earn", mu=mu, sigma=sigma, observed=earn)

    return model