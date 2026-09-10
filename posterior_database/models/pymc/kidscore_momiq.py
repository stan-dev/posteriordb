import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        beta = pm.Flat("beta", shape=2)
        sigma = pm.HalfCauchy("sigma", beta=2.5)
        
        mu = beta[0] + beta[1] * data['mom_iq']
        
        if not prior_only:
            kid_score_obs = pm.Normal("kid_score", mu=mu, sigma=sigma, observed=data['kid_score'])

    return model