import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        N = data['N']
        y_data = data['y']
        
        theta = pm.Uniform('theta', lower=0, upper=1)
        mu = pm.Normal('mu', mu=0, sigma=10, shape=2)

        w = pt.stack([theta, 1 - theta])

        if not prior_only:
            pm.NormalMixture('y', w=w, mu=mu, sigma=1.0, observed=y_data)

    return model