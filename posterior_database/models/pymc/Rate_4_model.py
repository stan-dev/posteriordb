import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        theta = pm.Uniform("theta", lower=0, upper=1)
        thetaprior = pm.Uniform("thetaprior", lower=0, upper=1)
        
        if not prior_only:
            k_obs = pm.Binomial("k", n=data['n'], p=theta, observed=data['k'])
        
        n = data['n']
        k = data['k']
        log_binom_coeff = pt.gammaln(n + 1) - pt.gammaln(k + 1) - pt.gammaln(n - k + 1)

    return model