import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    kid_score = data['kid_score']
    mom_work = data['mom_work']
    
    work2 = np.array(mom_work == 2, dtype=float)
    work3 = np.array(mom_work == 3, dtype=float)
    work4 = np.array(mom_work == 4, dtype=float)

    with pm.Model() as model:
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * work2 + beta[2] * work3 + beta[3] * work4)
        
        if not prior_only:
            kid_score_obs = pm.Normal("kid_score", mu=mu, sigma=sigma, observed=kid_score)

    return model