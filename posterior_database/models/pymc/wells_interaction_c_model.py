import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    switched = data['switched']
    dist = data['dist']
    arsenic = data['arsenic']
    c_dist100 = (dist - np.mean(dist)) / 100.0
    c_arsenic = arsenic - np.mean(arsenic)
    inter = c_dist100 * c_arsenic
    x = np.column_stack([c_dist100, c_arsenic, inter])

    with pm.Model() as model:
        alpha = pm.Flat("alpha")
        beta = pm.Flat("beta", shape=3)
        
        logit_p = alpha + x @ beta
        
        if not prior_only:
            switched_obs = pm.Bernoulli("switched", logit_p=logit_p, observed=switched)

    return model