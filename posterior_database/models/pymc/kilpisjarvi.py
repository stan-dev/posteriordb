import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        x = data['x']
        y = data['y']
        xpred = data['xpred']
        pmualpha = data['pmualpha']
        psalpha = data['psalpha']
        pmubeta = data['pmubeta']
        psbeta = data['psbeta']
        
        alpha = pm.Normal("alpha", mu=pmualpha, sigma=psalpha)
        beta = pm.Normal("beta", mu=pmubeta, sigma=psbeta)
        sigma = pm.HalfFlat("sigma")
        
        mu = alpha + beta * x
        
        if not prior_only:
            y_obs = pm.Normal("y", mu=mu, sigma=sigma, observed=y)

    return model