def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    y_data = data['y']  # Shape [M, T] - numpy array
    M = data['M'] 
    T = data['T']
    
    # Transformed data (compute before model)
    s = np.sum(y_data, axis=1)  # Row sums
    observed_mask = s > 0  # Boolean mask for observed individuals
    
    # Precompute numpy masks for likelihood
    observed_mask = s > 0
    n_unobs = int(np.sum(~observed_mask))

    with pm.Model() as model:
        # Convert data to pytensor constant
        y = pt.as_tensor_variable(y_data)

        # Parameters with uniform priors (implicit in Stan)
        omega = pm.Uniform("omega", lower=0, upper=1)
        p = pm.Uniform("p", lower=0, upper=1)
        c = pm.Uniform("c", lower=0, upper=1)
        
        # Compute effective capture probabilities
        # Initialize with first occasion probabilities (all p)
        p_eff = pt.zeros((M, T))
        p_eff = pt.set_subtensor(p_eff[:, 0], p)
        
        # For subsequent occasions, compute iteratively
        for j in range(1, T):
            # p_eff[i,j] = (1 - y[i,j-1]) * p + y[i,j-1] * c
            p_eff_j = (1.0 - y[:, j-1]) * p + y[:, j-1] * c
            p_eff = pt.set_subtensor(p_eff[:, j], p_eff_j)
        
        # Vectorized likelihood
        # Bernoulli logp for all individuals: shape (M, T)
        bernoulli_logp = y * pt.log(p_eff) + (1 - y) * pt.log(1 - p_eff)
        bern_logp_sum = pt.sum(bernoulli_logp, axis=1)  # shape (M,)

        # Observed individuals: z[i] = 1
        logp_obs = pt.log(omega) + bern_logp_sum[observed_mask]

        # Unobserved individuals: marginalize over z
        # For unobserved, y=0 for all t, so p_eff[:,0]=p and p_eff[:,j]=p for j>0
        # All unobserved individuals have identical p_eff rows, so same logp
        logp_z1_unobs = pt.log(omega) + bern_logp_sum[~observed_mask]
        logp_z0 = pt.log(1 - omega)
        logp_unobs = pm.math.logaddexp(logp_z1_unobs, logp_z0)

        pm.Potential("likelihood", pt.sum(logp_obs) + pt.sum(logp_unobs))
        
        # Generated quantities (deterministic transformations)
        omega_nd = pm.Deterministic(
            "omega_nd",
            (omega * (1 - p) ** T) / (omega * (1 - p) ** T + (1 - omega))
        )
        
        trap_response = pm.Deterministic("trap_response", c - p)
    
    return model