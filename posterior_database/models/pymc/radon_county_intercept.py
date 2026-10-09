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
        
        alpha = pm.Normal("alpha", mu=0, sigma=10, shape=J)
        beta = pm.Normal("beta", mu=0, sigma=10)
        sigma_y = pm.TruncatedNormal("sigma_y", mu=0, sigma=1, lower=0)
        
        mu = alpha[county_idx] + beta * floor_measure
        
        if not prior_only:
            y_obs = pm.Normal("log_radon", mu=mu, sigma=sigma_y, observed=log_radon)

    return model