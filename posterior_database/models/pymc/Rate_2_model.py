import pymc as pm
import pytensor.tensor as pt
import numpy as np
from scipy.special import gammaln

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        theta1 = pm.Uniform("theta1", lower=0, upper=1)
        theta2 = pm.Uniform("theta2", lower=0, upper=1)
        
        delta = pm.Deterministic("delta", theta1 - theta2)
        
        if not prior_only:
            k1_obs = pm.Binomial("k1", n=data['n1'], p=theta1, observed=data['k1'])
            k2_obs = pm.Binomial("k2", n=data['n2'], p=theta2, observed=data['k2'])

    return model