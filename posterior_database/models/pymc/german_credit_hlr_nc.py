import numpy as np
import pymc as pm
import pytensor.tensor as pt


def make_model(data: dict) -> pm.Model:
    X = np.asarray(data["X"], dtype=float)
    y = np.asarray(data["y"], dtype=int)
    N, D = X.shape
    assert N == int(data["N"]) and D == int(data["D"])

    with pm.Model() as model:
        sigma2 = pm.Exponential("sigma2", lam=0.01)
        sigma = pt.sqrt(sigma2)

        alpha_raw = pm.Normal("alpha_raw", 0.0, 1.0)
        beta_raw = pm.Normal("beta_raw", 0.0, 1.0, shape=D)

        alpha = pm.Deterministic("alpha", sigma * alpha_raw)
        beta = pm.Deterministic("beta", sigma * beta_raw)

        logits = alpha + pt.dot(X, beta)
        pm.Bernoulli("y_obs", logit_p=logits, observed=y)
    return model
