import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    nobs = data['nobs']
    nmis = data['nmis']
    nyear = data['nyear']
    nsite = data['nsite']
    obs = np.array(data['obs'])
    obsyear = np.array(data['obsyear']) - 1
    obssite = np.array(data['obssite']) - 1
    misyear = np.array(data['misyear']) - 1
    missite = np.array(data['missite']) - 1

    with pm.Model() as model:
        
        mu_alpha = pm.Normal("mu_alpha", mu=0, sigma=10)
        sd_alpha = pm.Uniform("sd_alpha", lower=0, upper=5)
        alpha = pm.Normal("alpha", mu=mu_alpha, sigma=sd_alpha, shape=nsite)
        
        log_lambda = pm.Deterministic("log_lambda", 
                                     pt.tile(alpha[None, :], (nyear, 1)))
        
        if not prior_only:
            pm.Poisson("obs", mu=pt.exp(log_lambda[obsyear, obssite]), observed=obs)
        
    return model