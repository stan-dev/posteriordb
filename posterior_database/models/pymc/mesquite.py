import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        weight = data['weight']
        diam1 = data['diam1']
        diam2 = data['diam2']
        canopy_height = data['canopy_height']
        total_height = data['total_height']
        density = data['density']
        group = data['group']
        
        beta = pm.Flat("beta", shape=7)
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * diam1 + beta[2] * diam2 + 
                             beta[3] * canopy_height + beta[4] * total_height + 
                             beta[5] * density + beta[6] * group)
        
        if not prior_only:
            pm.Normal("weight", mu=mu, sigma=sigma, observed=weight)

    return model