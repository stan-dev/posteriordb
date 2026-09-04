import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    weight = np.array(data['weight'])
    diam1 = np.array(data['diam1'])
    diam2 = np.array(data['diam2'])
    canopy_height = np.array(data['canopy_height'])
    total_height = np.array(data['total_height'])
    group = np.array(data['group'])
    
    log_weight = np.log(weight)
    log_canopy_volume = np.log(diam1 * diam2 * canopy_height)
    log_canopy_area = np.log(diam1 * diam2)
    log_canopy_shape = np.log(diam1 / diam2)
    log_total_height = np.log(total_height)

    with pm.Model() as model:
        beta = pm.Flat("beta", shape=6)
        
        sigma = pm.HalfFlat("sigma")
        
        mu = pm.Deterministic("mu", beta[0] + beta[1] * log_canopy_volume + 
                             beta[2] * log_canopy_area + 
                             beta[3] * log_canopy_shape + 
                             beta[4] * log_total_height + 
                             beta[5] * group)
        
        if not prior_only:
            pm.Normal("log_weight", mu=mu, sigma=sigma, observed=log_weight)

    return model