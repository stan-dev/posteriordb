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
        
        sigma_y = pm.HalfNormal("sigma_y", sigma=1)
        sigma_alpha = pm.HalfNormal("sigma_alpha", sigma=1)
        sigma_beta = pm.HalfNormal("sigma_beta", sigma=1)
        
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        mu_beta = pm.Normal("mu_beta", mu=0, sigma=10)
        
        alpha_raw = pm.Normal("alpha_raw", mu=0, sigma=1, shape=J)
        beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=J)
        
        alpha = pm.Deterministic("alpha", mu_alpha + sigma_alpha * alpha_raw)
        beta = pm.Deterministic("beta", mu_beta + sigma_beta * beta_raw)
        
        mu = pm.Deterministic("mu", alpha[county_idx] + floor_measure * beta[county_idx])
        
        if not prior_only:
            pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)

    return model