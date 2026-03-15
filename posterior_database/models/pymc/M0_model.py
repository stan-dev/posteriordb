def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    y = data['y']  # shape [M, T]
    M = data['M']
    T = data['T']
    
    # Transformed data (compute row sums and observed count)
    s = np.sum(y, axis=1)  # sum across columns for each row
    C = np.sum(s > 0)  # count of individuals with at least one capture
    
    # Precompute numpy arrays for likelihood
    s_arr = np.array(s, dtype=np.float64)
    obs_mask = s > 0
    s_obs = s_arr[obs_mask]
    n_unobs = int(np.sum(~obs_mask))

    with pm.Model() as model:
        # Parameters with uniform priors (implicit in Stan)
        omega = pm.Uniform("omega", lower=0, upper=1)  # Inclusion probability
        p = pm.Uniform("p", lower=0, upper=1)  # Detection probability

        # Observed individuals: z[i] = 1, binomial logp
        log_binom = pt.gammaln(T + 1) - pt.gammaln(s_obs + 1) - pt.gammaln(T - s_obs + 1)
        logp_obs = pt.log(omega) + log_binom + s_obs * pt.log(p) + (T - s_obs) * pt.log(1 - p)

        # Unobserved individuals: all have s=0, marginalize over z
        logp_z1_unobs = pt.log(omega) + T * pt.log(1 - p)
        logp_z0 = pt.log(1 - omega)
        logp_unobs = pm.math.logaddexp(logp_z1_unobs, logp_z0)

        pm.Potential("likelihood", pt.sum(logp_obs) + n_unobs * logp_unobs)
        
        # Generated quantities
        omega_nd = pm.Deterministic("omega_nd", 
                                   (omega * (1 - p)**T) / (omega * (1 - p)**T + (1 - omega)))
        
    return model