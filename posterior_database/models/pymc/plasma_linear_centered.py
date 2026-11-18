# plasma_linear_centered.py
"""
Linear Gaussian toy – centred parameterisation.
Matches plasma_linear_centered.stan (Langmore et al., arXiv:2103.07515).
"""
import numpy as np
import pymc as pm
import pytensor.tensor as pt


def build_L_pr(s, tau, delta):
    """Cholesky of C_pr[i,j] = exp(-(s_i-s_j)^2/(2 tau^2)) + delta * 1{i=j}."""
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

    L_pr = build_L_pr(s, tau, delta)  # constant; same as Stan transformed data

    with pm.Model() as model:
        # x ~ N(0, C_pr)  via Cholesky
        x = pm.MvNormal("x", mu=np.zeros(N), chol=L_pr, shape=N)
        pm.Normal("y_obs", mu=pt.dot(A, x), sigma=sigma, observed=y)
    return model
