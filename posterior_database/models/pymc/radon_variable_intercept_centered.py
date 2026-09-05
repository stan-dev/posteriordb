import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    county_idx_0based = np.array(data['county_idx']) - 1
    floor_measure = np.array(data['floor_measure'])

    with pm.Model() as model:
        sigma_y = pm.HalfNormal("sigma_y", sigma=1)
        sigma_alpha = pm.HalfNormal("sigma_alpha", sigma=1)
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        beta = pm.Normal("beta", mu=0, sigma=10)
        
        alpha = pm.Normal("alpha", mu=mu_alpha, sigma=sigma_alpha, shape=data['J'])
        
        mu = alpha[county_idx_0based] + floor_measure * beta
        
        if not prior_only:
            log_radon_obs = pm.Normal("log_radon", mu=mu, sigma=sigma_y, 
                                      observed=data['log_radon'])

    return model