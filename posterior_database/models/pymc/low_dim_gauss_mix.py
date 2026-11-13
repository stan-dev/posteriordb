import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        y_data = data['y']
        
        mu = pm.Normal("mu", mu=0, sigma=2, shape=2, transform=pm.distributions.transforms.ordered)
        sigma = pm.HalfNormal("sigma", sigma=2, shape=2)
        theta = pm.Beta("theta", alpha=5, beta=5)
        
        w = pt.stack([theta, 1 - theta])
        mu_components = pt.stack([mu[0], mu[1]])
        sigma_components = pt.stack([sigma[0], sigma[1]])
        
        if not prior_only:
            y_obs = pm.NormalMixture("y", w=w, mu=mu_components, sigma=sigma_components, observed=y_data)
        
    return model