import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        D = data['D'] 
        X = data['X']
        y = data['y']
        
        beta = pm.Normal("beta", mu=0, sigma=10, shape=D)
        sigma = pm.HalfNormal("sigma", sigma=10)
        
        mu = pm.Deterministic("mu", X @ beta)
        
        if not prior_only:
            y_obs = pm.Normal("y", mu=mu, sigma=sigma, observed=y)

    return model