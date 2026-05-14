import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    kid_score = np.array(data['kid_score'])
    mom_hs = np.array(data['mom_hs'])
    mom_iq = np.array(data['mom_iq'])
    
    c2_mom_hs = mom_hs - 0.5
    c2_mom_iq = mom_iq - 100.0
    inter = c2_mom_hs * c2_mom_iq
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * c2_mom_hs + beta[2] * c2_mom_iq + beta[3] * inter)
        
        if not prior_only:
            pm.Normal("kid_score", mu=mu, sigma=sigma, observed=kid_score)

    return model