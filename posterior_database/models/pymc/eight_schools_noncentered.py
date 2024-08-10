import numpy as np
import pymc as pm


def model(data):
    y_obs = np.array(data["y"])  # estimated treatment
    sigma = np.array(data["sigma"])  # std of estimated effect
    coords = {"school": np.arange(data["J"])}
    with pm.Model(coords=coords) as pymc_model:

        mu = pm.Normal(
            "mu", mu=0, sigma=5
        )  # hyper-parameter of mean, non-informative prior
        tau = pm.Cauchy("tau", alpha=0, beta=5)  # hyper-parameter of sigma
        theta_trans = pm.Normal("theta_trans", mu=0, sigma=1, dims="school")
        theta = mu + tau * theta_trans
        y = pm.Normal("y", mu=theta, sigma=sigma, observed=y_obs)
    return pymc_model
