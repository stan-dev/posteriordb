import pymc as pm
import pytensor.tensor as pt


def make_model(data):
    y = float(data["y"])
    sigma = float(data["sigma"])

    with pm.Model() as model:
        # matches Stan: vector[2] theta
        # theta[0] = θ₀, theta[1] = θ₁
        theta = pm.Normal("theta", mu=0.0, sigma=1.0, shape=2)

        # F = theta[1]^2 + theta[0]^2 * (theta[0]^2 - 0.5)
        F = pt.square(theta[1]) + pt.square(theta[0]) * (pt.square(theta[0]) - 0.5)

        pm.Normal("y_obs", mu=F, sigma=sigma, observed=y)

    return model
