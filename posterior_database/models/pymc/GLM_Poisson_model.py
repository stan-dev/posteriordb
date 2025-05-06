import numpy as np
import pymc as pm


def model(data):
    years_data = np.array(data["year"])
    counts_data = np.array(data["C"])
    number_observations = data["n"]
    coords = {
        "features": ["years", "years**2", "years**3"],
        "observation": np.arange(number_observations),
    }
    with pm.Model(coords=coords) as pymc_model:
        alpha = pm.Uniform("alpha", -20, +20)
        beta = pm.Uniform("beta", -10, +10, dims="features")
        X = pm.Data(
            "X",
            np.column_stack([years_data, years_data**2, years_data**3]),
            dims=["observation", "feature"],
        )
        y = pm.Data("y", counts_data, dims="observation")

        log_lambda = pm.Deterministic(
            "log_lambda", alpha + X @ beta, dims="observation"
        )

        counts = pm.Poisson(
            "counts", mu=pm.math.exp(log_lambda), observed=y, dims="observation"
        )

    return pymc_model

