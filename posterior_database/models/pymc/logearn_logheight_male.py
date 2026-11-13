import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    log_earn = np.log(data['earn'])
    log_height = np.log(data['height'])
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=3)
        sigma = pm.HalfFlat("sigma")
        
        mu = beta[0] + beta[1] * log_height + beta[2] * data['male']
        
        if not prior_only:
            log_earn_obs = pm.Normal("log_earn", mu=mu, sigma=sigma, observed=log_earn)
    
    return model