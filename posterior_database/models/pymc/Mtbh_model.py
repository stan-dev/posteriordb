def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    y_data = np.array(data['y'])  # shape (M, T) - convert to numpy array
    M = data['M']  # number of species
    T = data['T']  # number of occasions
    
    # Transformed data computations (same as Stan)
    s = np.sum(y_data, axis=1)  # detection counts per species
    C = int(np.sum(s > 0))  # number of observed species
    
    # Identify observed vs unobserved species for vectorized likelihood
    observed_mask = s > 0

    # Identify observed vs unobserved species for vectorized likelihood
    observed_mask = s > 0

    with pm.Model() as model:
        # Parameters - use Flat with manual bounds to match Stan's implicit uniform priors
        omega_raw = pm.Flat("omega")
        mean_p_raw = pm.Flat("mean_p", shape=T)
        gamma = pm.Normal("gamma", mu=0, sigma=10)  # recapture effect
        sigma_raw = pm.Flat("sigma")
        eps_raw = pm.Normal("eps_raw", mu=0, sigma=1, shape=M)  # standardized random effects
        
        # Apply constraints via transformations
        omega = pm.Deterministic("omega_constrained", pm.math.sigmoid(omega_raw))  # map to (0,1)
        mean_p = pm.Deterministic("mean_p_constrained", pm.math.sigmoid(mean_p_raw))  # map to (0,1)
        sigma = pm.Deterministic("sigma_constrained", 3 * pm.math.sigmoid(sigma_raw))  # map to (0,3)
        
        # Add Jacobians for transforms (log of derivative)
        pm.Potential("omega_jacobian", pt.log(omega * (1 - omega)))
        pm.Potential("mean_p_jacobian", pt.sum(pt.log(mean_p * (1 - mean_p))))
        pm.Potential("sigma_jacobian", pt.log(3 * sigma / 3 * (1 - sigma / 3)))
        
        # Transformed parameters
        eps = pm.Deterministic("eps_det", sigma * eps_raw)
        alpha = pm.Deterministic("alpha", pm.math.logit(mean_p))
        
        # Build logit_p matrix: shape (M, T) 
        # Stan indexing: logit_p[:, 1] uses 1-based indexing for columns
        # First occasion (j=1 in Stan, j=0 in Python): no recapture term
        logit_p_list = []
        
        # First column: alpha[1] + eps (Stan 1-based, so alpha[0] in Python)
        logit_p_col_0 = alpha[0] + eps
        logit_p_list.append(logit_p_col_0)
        
        # Subsequent occasions (j=2 to T in Stan, j=1 to T-1 in Python)
        for j in range(1, T):
            # logit_p[i, j] = alpha[j] + eps[i] + gamma * y[i, j-1]
            # y[i, j-1] is the previous occasion's detection
            logit_p_col_j = alpha[j] + eps + gamma * y_data[:, j-1]
            logit_p_list.append(logit_p_col_j)
        
        # Stack to get matrix shape (M, T)
        logit_p = pt.stack(logit_p_list, axis=1)  # shape (M, T)
        pm.Deterministic("logit_p_det", logit_p)
        
        # Likelihood using vectorized capture-recapture pattern
        # Split into observed and unobserved species
        if np.any(observed_mask):
            # For observed species: z[i] = 1 certain
            y_obs = y_data[observed_mask]  # shape (n_observed, T)
            logit_p_obs = logit_p[observed_mask]  # shape (n_observed, T) 
            
            # log P(z=1) + log P(y | z=1, logit_p)
            logp_obs_z = pt.log(omega)  # log P(z=1)
            # Vectorized bernoulli logit likelihood: sum over occasions per species
            logp_obs_y = pt.sum(
                pm.logp(pm.Bernoulli.dist(logit_p=logit_p_obs), y_obs), axis=1
            )  # shape (n_observed,)
            logp_obs = logp_obs_z + logp_obs_y  # broadcast scalar + vector
            total_logp_obs = pt.sum(logp_obs)
        else:
            total_logp_obs = pt.as_tensor(0.0)
            
        if np.any(~observed_mask):
            # For unobserved species: marginalize over z[i]
            y_unobs = y_data[~observed_mask]  # shape (n_unobserved, T)
            logit_p_unobs = logit_p[~observed_mask]  # shape (n_unobserved, T)
            
            # log P(z=1) + log P(y=all_zeros | z=1, logit_p)
            logp_unobs_z1_prior = pt.log(omega)  # scalar
            logp_unobs_z1_lik = pt.sum(
                pm.logp(pm.Bernoulli.dist(logit_p=logit_p_unobs), y_unobs), axis=1
            )  # shape (n_unobserved,)
            logp_unobs_z1 = logp_unobs_z1_prior + logp_unobs_z1_lik
            
            # log P(z=0)
            logp_unobs_z0 = pt.log(1 - omega)  # scalar
            
            # log_sum_exp marginalization
            logp_unobs = pm.math.logaddexp(logp_unobs_z1, logp_unobs_z0)
            total_logp_unobs = pt.sum(logp_unobs)
        else:
            total_logp_unobs = pt.as_tensor(0.0)
        
        # Add likelihood potential
        total_logp = total_logp_obs + total_logp_unobs
        pm.Potential("likelihood", total_logp)
        
        # Generated quantities
        p = pm.Deterministic("p", pm.math.invlogit(logit_p))
    
    return model