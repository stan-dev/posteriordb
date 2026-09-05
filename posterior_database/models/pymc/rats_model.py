import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    Npts = data['Npts']
    rat = np.array(data['rat']) - 1
    x = np.array(data['x'])
    y = np.array(data['y'])
    xbar = data['xbar']

    with pm.Model() as model:
        
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=100)
        mu_beta = pm.Normal("mu_beta", mu=0, sigma=100)
        
        sigma_y = pm.HalfFlat("sigma_y")
        sigma_alpha = pm.HalfFlat("sigma_alpha") 
        sigma_beta = pm.HalfFlat("sigma_beta")
        
        alpha = pm.Normal("alpha", mu=mu_alpha, sigma=sigma_alpha, shape=N)
        beta = pm.Normal("beta", mu=mu_beta, sigma=sigma_beta, shape=N)
        
        mu_y = pm.Deterministic("mu_y", alpha[rat] + beta[rat] * (x - xbar))
        
        if not prior_only:
            y_obs = pm.Normal("y", mu=mu_y, sigma=sigma_y, observed=y)
        
        alpha0 = pm.Deterministic("alpha0", mu_alpha - xbar * mu_beta)
        
    return model