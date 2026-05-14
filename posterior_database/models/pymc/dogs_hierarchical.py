import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    n_dogs = data['n_dogs']
    n_trials = data['n_trials'] 
    y_data = np.array(data['y'])
    
    J = n_dogs
    T = n_trials
    prev_shock = np.hstack([np.zeros((J, 1)), np.cumsum(y_data[:, :-1], axis=1)])
    prev_avoid = np.hstack([np.zeros((J, 1)), np.cumsum(1 - y_data[:, :-1], axis=1)])

    with pm.Model() as model:
        a = pm.Uniform("a", lower=0, upper=1)
        b = pm.Uniform("b", lower=0, upper=1)
        
        p = pm.Deterministic("p", a ** prev_shock * b ** prev_avoid)
        
        if not prior_only:
            y_obs = pm.Bernoulli("y", p=p, observed=y_data)

    return model