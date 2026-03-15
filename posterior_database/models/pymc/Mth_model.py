def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    y_data = data['y']  # shape [M, T]
    M = data['M']  # 387
    T = data['T']  # 5
    
    # Transformed data (compute before model)
    s = np.sum(y_data, axis=1)  # row sums
    C = np.sum(s > 0)  # count of observed individuals
    
    # Precompute numpy masks for likelihood
    observed_mask = s > 0  # boolean mask for observed individuals
    never_detected_mask = s == 0  # boolean mask for never detected
    observed_indices = np.where(observed_mask)[0]
    never_detected_indices = np.where(never_detected_mask)[0]

    with pm.Model() as model:
        # Parameters with uniform priors (Stan defaults)
        omega = pm.Uniform("omega", lower=0, upper=1)
        mean_p = pm.Uniform("mean_p", lower=0, upper=1, shape=T)
        sigma = pm.Uniform("sigma", lower=0, upper=5)
        eps_raw = pm.Normal("eps_raw", mu=0, sigma=1, shape=M)

        # Transformed parameters
        eps = pm.Deterministic("eps", sigma * eps_raw)
        mean_lp = pm.Deterministic("mean_lp", pm.math.logit(mean_p))

        # Build logit_p matrix: each column j gets mean_lp[j] + eps
        logit_p = pm.Deterministic("logit_p", mean_lp[None, :] + eps[:, None])

        # Likelihood - vectorized version of the Stan loops
        # For individuals with s[i] > 0: bernoulli(1 | omega) + bernoulli_logit(y[i] | logit_p[i])
        # For individuals with s[i] == 0: log_sum_exp of two terms
        
        # For observed individuals (s[i] > 0)
        if np.any(observed_mask):
            # bernoulli_lpmf(1 | omega) 
            logp_omega_1 = pm.logp(pm.Bernoulli.dist(p=omega), 1)
            # bernoulli_logit_lpmf(y[i] | logit_p[i]) for each observed individual
            for i in observed_indices:
                logp_y_i = pt.sum(pm.logp(pm.Bernoulli.dist(logit_p=logit_p[i]), y_data[i]))
                pm.Potential(f"obs_{i}", logp_omega_1 + logp_y_i)
        
        # For never detected individuals (s[i] == 0)
        if np.any(never_detected_mask):
            logp_omega_1 = pm.logp(pm.Bernoulli.dist(p=omega), 1)
            logp_omega_0 = pm.logp(pm.Bernoulli.dist(p=omega), 0)
            
            for i in never_detected_indices:
                # First term: bernoulli_lpmf(1 | omega) + bernoulli_logit_lpmf(y[i] | logit_p[i])
                logp_y_i = pt.sum(pm.logp(pm.Bernoulli.dist(logit_p=logit_p[i]), y_data[i]))
                term1 = logp_omega_1 + logp_y_i
                # Second term: bernoulli_lpmf(0 | omega)
                term2 = logp_omega_0
                # log_sum_exp of the two terms
                pm.Potential(f"never_det_{i}", pm.math.logsumexp([term1, term2]))
    
    return model