import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    kid_score = data['kid_score']
    mom_hs = data['mom_hs']
    mom_iq = data['mom_iq']
    c_mom_hs = mom_hs - np.mean(mom_hs)
    c_mom_iq = mom_iq - np.mean(mom_iq)
    inter = c_mom_hs * c_mom_iq

    with pm.Model() as model:
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfFlat("sigma")
        
        mu = beta[0] + beta[1] * c_mom_hs + beta[2] * c_mom_iq + beta[3] * inter
        
        if not prior_only:
            pm.Normal("kid_score", mu=mu, sigma=sigma, observed=kid_score)

    return model