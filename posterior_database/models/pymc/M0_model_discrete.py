import numpy as np
import pymc as pm

def model(data):
    y = np.array(data["y"])  # capture history matrix
    T = np.array(data["T"])  # time periods
    coords = {"individual": np.arange(data["M"]),
              "capture_period": np.arange(data["T"])}
    with pm.Model(coords=coords) as pymc_model:

        # Inclusion probability
        omega = pm.Uniform("omega", 0, 1)
        # Capture probability
        p = pm.Uniform("p", 0, 1) 

        # Inclusion indicator
        z = pm.Bernoulli("z", p=omega, dims="individual")
    
        y_obs = pm.Bernoulli("y_obs", p=z[:, None]*p, observed=y, dims=("individual", "capture_period"))

        N = pm.Deterministic("N", pm.math.sum(z))

        omega_nd = pm.Deterministic("omega_nd", (omega * (1 -p)**T)  / (omega * (1 - p)**T  + (1 - omega)))

    return pymc_model