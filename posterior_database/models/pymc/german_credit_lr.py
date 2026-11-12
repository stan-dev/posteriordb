import numpy as np
import pymc as pm
import pytensor.tensor as pt


def make_model(data: dict) -> pm.Model:
    X = np.asarray(data["X"], dtype=float)
    y = np.asarray(data["y"], dtype=int)
    N, D = X.shape
    assert N == int(data["N"]) and D == int(data["D"])

    with pm.Model() as model:
        alpha = pm.Normal("alpha", mu=0.0, sigma=10.0)
        beta = pm.Normal("beta", mu=0.0, sigma=10.0, shape=D)
        logits = alpha + pt.dot(X, beta)
        pm.Bernoulli("y_obs", logit_p=logits, observed=y)
    return model
