import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    J = data['J']
    county = np.array(data['county']) - 1
    y_obs = np.array(data['y'])

    with pm.Model() as model:
        
        mu_a = pm.Normal("mu_a", mu=0, sigma=1)
        sigma_a = pm.Uniform("sigma_a", lower=0, upper=100)
        sigma_y = pm.Uniform("sigma_y", lower=0, upper=100)
        
        a = pm.Normal("a", mu=mu_a, sigma=sigma_a, shape=J)
        
        y_hat = a[county]
        
        if not prior_only:
            pm.Normal("y", mu=y_hat, sigma=sigma_y, observed=y_obs)

    return model