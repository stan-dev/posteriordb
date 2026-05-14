import pymc as pm
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    switched = data['switched']
    dist = np.array(data['dist'])
    dist100 = dist / 100.0

    with pm.Model() as model:
        alpha = pm.Flat("alpha")
        beta = pm.Flat("beta")
        
        logit_p = alpha + dist100 * beta
        
        if not prior_only:
            pm.Bernoulli("switched", logit_p=logit_p, observed=switched)

    return model