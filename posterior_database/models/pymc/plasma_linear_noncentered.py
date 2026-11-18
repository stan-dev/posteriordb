# plasma_linear_noncentered.py
"""
Linear Gaussian toy – non-centred parameterisation.
Matches plasma_linear_noncentered.stan (Langmore et al., arXiv:2103.07515).
"""
import numpy as np
import pymc as pm
import pytensor.tensor as pt


def build_L_pr(s, tau, delta):
    s = np.asarray(s, dtype=float)
    C = np.exp(-((s[:, None] - s[None, :]) ** 2) / (2 * tau**2))
    C = C + delta * np.eye(len(s))
    return np.linalg.cholesky(C)


def make_model(data: dict) -> pm.Model:
    N = int(data["N"])
    s = np.asarray(data["s"], dtype=float)
    A = np.asarray(data["A"], dtype=float)
    y = np.asarray(data["y"], dtype=float)
    sigma = float(data["sigma"])
    tau = float(data["tau"])
    delta = float(data["delta"])

    L_pr = build_L_pr(s, tau, delta)

    with pm.Model() as model:
        Z = pm.Normal("Z", 0.0, 1.0, shape=N)
        x = pm.Deterministic("x", pt.dot(L_pr, Z))  # same name as Stan transformed param
        pm.Normal("y_obs", mu=pt.dot(A, x), sigma=sigma, observed=y)
    return model
