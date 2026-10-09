import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    kid_score = np.array(data['kid_score'])
    mom_iq = np.array(data['mom_iq']) 
    mom_hs = np.array(data['mom_hs'])
    
    inter = mom_hs * mom_iq
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfCauchy("sigma", beta=2.5)
        
        mu = beta[0] + beta[1] * mom_hs + beta[2] * mom_iq + beta[3] * inter
        
        if not prior_only:
            pm.Normal("kid_score", mu=mu, sigma=sigma, observed=kid_score)
        
    return model