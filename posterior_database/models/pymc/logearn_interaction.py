import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    earn = np.array(data['earn'], dtype=float)
    height = np.array(data['height'], dtype=float)
    male = np.array(data['male'], dtype=float)
    
    log_earn = np.log(earn)
    inter = height * male
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * height + beta[2] * male + beta[3] * inter)
        
        if not prior_only:
            log_earn_obs = pm.Normal("log_earn", mu=mu, sigma=sigma, observed=log_earn)
    
    return model