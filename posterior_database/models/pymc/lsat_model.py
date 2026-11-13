import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    R = data['R']
    T = data['T']
    culm = data['culm']
    response = data['response']
    
    culm = np.array(culm)
    response = np.array(response)
    
    counts = np.diff(np.concatenate([[0], culm]))
    r = np.repeat(response, counts, axis=0).T
    
    with pm.Model() as model:
        alpha = pm.Normal("alpha", mu=0, sigma=100, shape=T)
        theta = pm.Normal("theta", mu=0, sigma=1, shape=N)
        beta = pm.HalfNormal("beta", sigma=100)
        
        logit_p = beta * theta[None, :] - alpha[:, None]
        
        if not prior_only:
            pm.Bernoulli("r", logit_p=logit_p, observed=r)
        
        mean_alpha = pm.Deterministic("mean_alpha", pt.mean(alpha))
        a = pm.Deterministic("a", alpha - mean_alpha)
    
    return model