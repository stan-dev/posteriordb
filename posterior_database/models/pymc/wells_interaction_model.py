import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    switched = np.array(data['switched'])
    dist = np.array(data['dist'])
    arsenic = np.array(data['arsenic'])
    
    dist100 = dist / 100.0
    inter = dist100 * arsenic
    
    X = np.column_stack([dist100, arsenic, inter])

    with pm.Model() as model:
        alpha = pm.Flat("alpha")
        beta = pm.Flat("beta", shape=3)
        
        logit_p = alpha + X @ beta
        
        if not prior_only:
            switched_obs = pm.Bernoulli("switched", logit_p=logit_p, observed=switched)

    return model