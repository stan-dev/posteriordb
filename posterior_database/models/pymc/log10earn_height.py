import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    earn = data['earn']
    height = data['height']
    
    log10_earn = np.log10(earn)
    
    with pm.Model() as model:
        beta = pm.Flat("beta", shape=2)
        sigma = pm.HalfFlat("sigma")
        
        mu = beta[0] + beta[1] * height
        
        if not prior_only:
            pm.Normal("log10_earn", mu=mu, sigma=sigma, observed=log10_earn)

    return model