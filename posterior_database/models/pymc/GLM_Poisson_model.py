import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    n = data['n']
    C = np.asarray(data['C'])
    year = np.asarray(data['year'])
    
    year_squared = year**2
    year_cubed = year_squared * year

    with pm.Model() as model:
        alpha = pm.Uniform("alpha", lower=-20, upper=20)
        beta1 = pm.Uniform("beta1", lower=-10, upper=10)
        beta2 = pm.Uniform("beta2", lower=-10, upper=10)
        beta3 = pm.Uniform("beta3", lower=-10, upper=10)
        
        log_lambda = pm.Deterministic("log_lambda", 
            alpha + beta1 * year + beta2 * year_squared + beta3 * year_cubed)
        
        lambda_gq = pm.Deterministic("lambda", pt.exp(log_lambda))
        
        if not prior_only:
            pm.Poisson("C", mu=pt.exp(log_lambda), observed=C)

    return model