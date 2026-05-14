import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    earn = data['earn']
    height = data['height']
    male = data['male']
    
    log_earn = np.log(earn)
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=3)
        sigma = pm.HalfFlat("sigma")
        
        mu = beta[0] + beta[1] * height + beta[2] * male
        
        if not prior_only:
            log_earn_obs = pm.Normal("log_earn", mu=mu, sigma=sigma, observed=log_earn)
    
    return model