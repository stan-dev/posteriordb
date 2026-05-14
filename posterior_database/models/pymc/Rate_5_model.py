import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    with pm.Model() as model:
        theta = pm.Beta("theta", alpha=1, beta=1)
        
        if not prior_only:
            k1_obs = pm.Binomial("k1", n=data["n1"], p=theta, observed=data["k1"])
            k2_obs = pm.Binomial("k2", n=data["n2"], p=theta, observed=data["k2"])

    return model