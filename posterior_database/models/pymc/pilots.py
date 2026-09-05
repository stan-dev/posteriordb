import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    group_idx = np.array(data['group_id']) - 1
    scenario_idx = np.array(data['scenario_id']) - 1
    
    with pm.Model() as model:
        mu_a = pm.Normal("mu_a", mu=0, sigma=1)
        sigma_a = pm.Uniform("sigma_a", lower=0, upper=100)
        
        a = pm.Normal("a", mu=10 * mu_a, sigma=sigma_a, shape=data['n_groups'])
        
        mu_b = pm.Normal("mu_b", mu=0, sigma=1)
        sigma_b = pm.Uniform("sigma_b", lower=0, upper=100)
        
        b = pm.Normal("b", mu=10 * mu_b, sigma=sigma_b, shape=data['n_scenarios'])
        
        sigma_y = pm.Uniform("sigma_y", lower=0, upper=100)
        
        y_hat = a[group_idx] + b[scenario_idx]
        
        if not prior_only:
            y_obs = pm.Normal("y", mu=y_hat, sigma=sigma_y, observed=data['y'])
        
    return model