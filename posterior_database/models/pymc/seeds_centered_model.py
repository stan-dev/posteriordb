import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    I = data['I']
    n = np.array(data['n'])
    N = np.array(data['N'])
    x1 = np.array(data['x1'], dtype=float)
    x2 = np.array(data['x2'], dtype=float)
    
    x1x2 = x1 * x2
    
    with pm.Model() as model:
        alpha0 = pm.Normal("alpha0", mu=0.0, sigma=1.0)
        alpha1 = pm.Normal("alpha1", mu=0.0, sigma=1.0)
        alpha12 = pm.Normal("alpha12", mu=0.0, sigma=1.0)
        alpha2 = pm.Normal("alpha2", mu=0.0, sigma=1.0)
        
        sigma = pm.HalfCauchy("sigma", beta=1.0)
        
        c = pm.Normal("c", mu=0.0, sigma=sigma, shape=I)
        
        b = pm.Deterministic("b", c - pt.mean(c))
        
        eta = alpha0 + alpha1 * x1 + alpha2 * x2 + alpha12 * x1x2 + b
        
        if not prior_only:
            n_obs = pm.Binomial("n", n=N, logit_p=eta, observed=n)
        
    return model