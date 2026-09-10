import pymc as pm
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    K = data['K']
    N = data['N']
    y = data['y']

    with pm.Model() as model:
        theta = pm.Dirichlet("theta", a=np.ones(K))
        mu = pm.Normal("mu", mu=0, sigma=10, shape=K)
        sigma = pm.Uniform("sigma", lower=0, upper=10, shape=K)
        
        if not prior_only:
            y_obs = pm.NormalMixture("y", w=theta, mu=mu, sigma=sigma, observed=y)

    return model