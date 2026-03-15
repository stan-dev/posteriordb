def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    y = np.array(data['y'])  # shape [M, T]
    M = data['M']
    T = data['T']
    
    # Transformed data - compute row sums and count observed individuals
    s = np.sum(y, axis=1)  # row sums
    C = np.sum(s > 0)  # count of observed individuals
    
    # Precompute numpy arrays for likelihood
    y_arr = np.array(y, dtype=np.float64)
    obs_mask = s > 0
    n_unobs = int(np.sum(~obs_mask))

    with pm.Model() as model:
        # Parameters with implicit uniform priors
        omega = pm.Uniform("omega", lower=0, upper=1)
        p = pm.Uniform("p", lower=0, upper=1, shape=T)

        # Bernoulli logp for all individuals: shape (M, T)
        bernoulli_logp = y_arr * pt.log(p)[None, :] + (1 - y_arr) * pt.log(1 - p)[None, :]

        # Observed individuals: z[i] = 1
        logp_obs = pt.log(omega) + pt.sum(bernoulli_logp[obs_mask], axis=1)

        # Unobserved individuals: marginalize over z
        logp_z1 = pt.log(omega) + pt.sum(pt.log(1 - p))
        logp_z0 = pt.log(1 - omega)
        logp_unobs = pm.math.logaddexp(logp_z1, logp_z0)

        pm.Potential("likelihood", pt.sum(logp_obs) + n_unobs * logp_unobs)
        
        # Generated quantities as deterministic variables
        pr = pm.Deterministic("pr", pt.prod(1 - p))
        omega_nd = pm.Deterministic("omega_nd", (omega * pr) / (omega * pr + (1 - omega)))
        
    return model