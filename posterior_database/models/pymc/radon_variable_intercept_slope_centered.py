import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    J = data['J']
    county_idx = np.array(data['county_idx']) - 1
    floor_measure = np.array(data['floor_measure'])
    log_radon = np.array(data['log_radon'])
    
    with pm.Model() as model:
        sigma_y = pm.TruncatedNormal("sigma_y", mu=0, sigma=1, lower=0)
        sigma_alpha = pm.TruncatedNormal("sigma_alpha", mu=0, sigma=1, lower=0)
        sigma_beta = pm.TruncatedNormal("sigma_beta", mu=0, sigma=1, lower=0)
        
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        mu_beta = pm.Normal("mu_beta", mu=0, sigma=10)
        
        alpha = pm.Normal("alpha", mu=mu_alpha, sigma=sigma_alpha, shape=J)
        beta = pm.Normal("beta", mu=mu_beta, sigma=sigma_beta, shape=J)
        
        mu = alpha[county_idx] + floor_measure * beta[county_idx]
        
        if not prior_only:
            y_obs = pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)
        
    return model