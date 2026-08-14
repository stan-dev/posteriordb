import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    income = np.array(data['income'])
    vote = np.array(data['vote'])
    x = income.reshape(-1, 1)

    with pm.Model() as model:
        alpha = pm.Flat("alpha")
        beta = pm.Flat("beta", shape=1)
        
        logit_p = alpha + (x * beta).flatten()
        
        if not prior_only:
            vote_obs = pm.Bernoulli("vote", logit_p=logit_p, observed=vote)

    return model