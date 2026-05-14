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
        alpha_raw = pm.Normal("alpha_raw", mu=0, sigma=1, shape=J)
        beta = pm.Normal("beta", mu=0, sigma=10)
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        sigma_alpha = pm.TruncatedNormal("sigma_alpha", mu=0, sigma=1, lower=0)
        sigma_y = pm.TruncatedNormal("sigma_y", mu=0, sigma=1, lower=0)
        
        alpha = pm.Deterministic("alpha", mu_alpha + sigma_alpha * alpha_raw)
        
        mu = alpha[county_idx] + floor_measure * beta
        
        if not prior_only:
            pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)

    return model