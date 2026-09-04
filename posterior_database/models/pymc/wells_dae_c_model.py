import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    switched = np.array(data['switched'])
    dist = np.array(data['dist'])
    arsenic = np.array(data['arsenic'])
    educ = np.array(data['educ'])
    c_dist100 = (dist - np.mean(dist)) / 100.0
    c_arsenic = arsenic - np.mean(arsenic)
    da_inter = c_dist100 * c_arsenic
    educ4 = educ / 4.0
    x = np.column_stack([c_dist100, c_arsenic, da_inter, educ4])

    with pm.Model() as model:
        alpha = pm.Flat("alpha")
        beta = pm.Flat("beta", shape=4)
        
        eta = alpha + x @ beta
        
        if not prior_only:
            y_obs = pm.Bernoulli("switched", logit_p=eta, observed=switched)

    return model