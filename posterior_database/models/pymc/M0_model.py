import numpy as np
import pymc as pm

def model(data):
    y = np.array(data["y"])  # capture history matrix
    T = np.array(data["T"])  # time periods
 
    coords = {"individual": np.arange(data["M"]),
              "capture_period": np.arange(data["T"])}
    with pm.Model(coords=coords) as pymc_model:
        y_data = pm.Data("y", y, dims=("individual", "capture_period"))
        s = pm.Deterministic("s", y_data.sum(axis=1), dims="individual")
        is_observed = s > 0
    
        # Inclusion probability
        omega = pm.Uniform("omega", 0, 1)
        # Capture probability
        p = pm.Uniform("p", 0, 1) 

        # Defining bernoulli and binomial components
        binom = pm.Binomial.dist(n=T, p=p)
        log_omega = pm.math.log(omega)
        log_one_minus_omega = pm.math.log(1-omega)
        log_one_minus_p = pm.math.log(1-p)

        # Computing marginalization mixture
        logp_if_obs = log_omega + pm.logp(binom, s)
        logp_zero_single = pm.math.logaddexp(log_omega + T * log_one_minus_p , log_one_minus_omega)
        logp_each = pm.math.switch(is_observed, logp_if_obs, logp_zero_single)

        pm.Potential("likelihood", logp_each.sum())
        
        omega_nd = pm.Deterministic("omega_nd", (omega * (1 -p)**T)  / (omega * (1 - p)**T  + (1 - omega)))
    
    return pymc_model