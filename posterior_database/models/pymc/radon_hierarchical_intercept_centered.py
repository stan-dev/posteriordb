import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    J = data['J'] 
    county_idx = np.array(data['county_idx']) - 1
    log_uppm = np.array(data['log_uppm'])
    floor_measure = np.array(data['floor_measure'])
    log_radon = np.array(data['log_radon'])

    with pm.Model() as model:
        sigma_alpha = pm.TruncatedNormal("sigma_alpha", mu=0, sigma=1, lower=0)
        sigma_y = pm.TruncatedNormal("sigma_y", mu=0, sigma=1, lower=0)
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        beta = pm.Normal("beta", mu=0, sigma=10, shape=2)
        
        alpha = pm.Normal("alpha", mu=mu_alpha, sigma=sigma_alpha, shape=J)
        
        muj = alpha[county_idx] + log_uppm * beta[0]
        mu = muj + floor_measure * beta[1]
        
        if not prior_only:
            y_obs = pm.Normal("y_obs", mu=mu, sigma=sigma_y, observed=log_radon)

    return model