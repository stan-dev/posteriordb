import pymc3 as pm3


def model(data):
    J = data["J"]  # number of schools
    y_obs = data["y"]  # estimated treatment
    sigma = data["sigma"]  # std of estimated effect
    with pm3.Model() as pymc_model:

        mu = pm3.Normal(
            "mu", mu=0, sd=5
        )  # hyper-parameter of mean, non-informative prior
        tau = pm3.Cauchy("tau", alpha=0, beta=5)  # hyper-parameter of sd
        theta_trans = pm3.Normal("theta_trans", mu=0, sd=1, shape=J)
        theta = mu + tau * theta_trans
        y = pm3.Normal("y", mu=theta, sd=sigma, observed=y_obs)
    return pymc_model
