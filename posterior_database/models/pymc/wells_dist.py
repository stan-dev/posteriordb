import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        switched = data['switched']
        dist = data['dist']
        
        beta = pm.Flat("beta", shape=2)
        
        logit_p = beta[0] + beta[1] * dist
        
        if not prior_only:
            switched_obs = pm.Bernoulli("switched", logit_p=logit_p, observed=switched)

    return model