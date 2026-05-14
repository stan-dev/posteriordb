import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    earn = data['earn']
    height = data['height']
    male = data['male']
    
    log_earn = np.log(earn)
    z_height = (height - np.mean(height)) / np.std(height)
    inter = z_height * male
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=4)
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * z_height + beta[2] * male + beta[3] * inter)
        
        if not prior_only:
            pm.Normal("log_earn", mu=mu, sigma=sigma, observed=log_earn)
        
    return model