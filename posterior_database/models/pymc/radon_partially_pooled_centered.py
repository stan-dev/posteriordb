import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    J = data['J'] 
    county_idx = np.array(data['county_idx']) - 1
    log_radon = data['log_radon']
    
    with pm.Model() as model:
        sigma_y = pm.HalfNormal("sigma_y", sigma=1)
        sigma_alpha = pm.HalfNormal("sigma_alpha", sigma=1) 
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        
        alpha = pm.Normal("alpha", mu=mu_alpha, sigma=sigma_alpha, shape=J)
        
        mu = alpha[county_idx]
        
        if not prior_only:
            pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)
        
    return model