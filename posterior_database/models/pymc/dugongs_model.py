import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    x = data['x']
    Y = data['Y']
    
    with pm.Model() as model:
        alpha = pm.Normal("alpha", mu=0.0, sigma=1000)
        beta = pm.Normal("beta", mu=0.0, sigma=1000)
        lambda_ = pm.Uniform("lambda", lower=0.5, upper=1.0)
        tau = pm.Gamma("tau", alpha=0.0001, beta=0.0001)
        
        sigma = pm.Deterministic("sigma", 1 / pt.sqrt(tau))
        U3 = pm.Deterministic("U3", pm.math.logit(lambda_))
        
        m = pm.Deterministic("m", alpha - beta * pt.power(lambda_, x))
        
        if not prior_only:
            Y_obs = pm.Normal("Y", mu=m, sigma=sigma, observed=Y)
    
    return model