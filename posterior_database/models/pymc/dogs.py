import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    n_dogs = data['n_dogs']
    n_trials = data['n_trials']
    y_data = np.array(data['y'])
    n_avoid = np.hstack([np.zeros((n_dogs, 1)), np.cumsum(1 - y_data[:, :-1], axis=1)])
    n_shock = np.hstack([np.zeros((n_dogs, 1)), np.cumsum(y_data[:, :-1], axis=1)])

    with pm.Model() as model:
        beta = pm.Normal("beta", mu=0, sigma=100, shape=3)
        
        logit_p = beta[0] + beta[1] * n_avoid + beta[2] * n_shock
        
        if not prior_only:
            pm.Bernoulli("y", logit_p=logit_p, observed=y_data)

    return model