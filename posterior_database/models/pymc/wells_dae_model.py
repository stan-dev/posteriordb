import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    switched = np.array(data['switched'])
    dist = np.array(data['dist'])
    arsenic = np.array(data['arsenic'])
    educ = np.array(data['educ'])
    
    dist100 = dist / 100.0
    educ4 = educ / 4.0
    
    x = np.column_stack([dist100, arsenic, educ4])

    with pm.Model() as model:
        alpha = pm.Flat("alpha")
        beta = pm.Flat("beta", shape=3)
        
        eta = pm.Deterministic("eta", alpha + x @ beta)
        
        if not prior_only:
            switched_obs = pm.Bernoulli("switched", logit_p=eta, observed=switched)

    return model