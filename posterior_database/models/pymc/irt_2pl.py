import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    I = data['I']
    J = data['J']
    y = data['y']
    
    with pm.Model() as model:
        sigma_theta = pm.HalfCauchy("sigma_theta", beta=2)
        theta = pm.Normal("theta", mu=0, sigma=sigma_theta, shape=J)
        sigma_a = pm.HalfCauchy("sigma_a", beta=2)
        a = pm.LogNormal("a", mu=0, sigma=sigma_a, shape=I)
        mu_b = pm.Normal("mu_b", mu=0, sigma=5)
        sigma_b = pm.HalfCauchy("sigma_b", beta=2)
        b = pm.Normal("b", mu=mu_b, sigma=sigma_b, shape=I)
        
        logit_p = a[:, None] * (theta[None, :] - b[:, None])
        
        if not prior_only:
            y_obs = pm.Bernoulli("y", logit_p=logit_p, observed=y)
    
    return model