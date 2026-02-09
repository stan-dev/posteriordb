import numpy as np
import pymc as pm

def model(data):

    # Define PyMC Model
    coords = {
        'obs_idx': np.arange(data["N"]),
        'feature': ['intercept', 'height']
    }
    
    with pm.Model(coords=coords) as earn_height:
        N = pm.Data("N", data["N"])
        earn = pm.Data('earn', data['earn'], dims=['obs_idx'])
        height = pm.Data('height', data['height'], dims=['obs_idx'])
        
        beta = pm.Flat('beta', dims=['feature'])
        mu = beta[0] + beta[1] * height
        
        sigma = pm.HalfFlat('sigma')
        earn_hat = pm.Normal('earn_hat', mu=mu, sigma=sigma, observed=earn, dims=['obs_idx'])

    return earn_height