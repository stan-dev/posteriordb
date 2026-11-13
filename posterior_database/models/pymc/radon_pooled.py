import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False):
    
    N = data['N']
    floor_measure = data['floor_measure']
    log_radon = data['log_radon']
    
    with pm.Model() as model:
        alpha = pm.Normal("alpha", mu=0, sigma=10)
        beta = pm.Normal("beta", mu=0, sigma=10)
        sigma_y = pm.HalfNormal("sigma_y", sigma=1)
        
        mu = pm.Deterministic("mu", alpha + beta * floor_measure)
        
        if not prior_only:
            pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)
        
    return model