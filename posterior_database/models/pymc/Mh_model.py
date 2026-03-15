def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    M = data['M']  # Size of augmented data set
    T = data['T']  # Number of sampling occasions  
    y = np.array(data['y'])  # Capture-history vector
    
    # Precompute numpy masks for likelihood
    observed_mask = y > 0
    unobserved_mask = y == 0

    with pm.Model() as model:
        # Parameters with uniform priors (implicit in Stan)
        omega = pm.Uniform("omega", lower=0, upper=1)
        mean_p = pm.Uniform("mean_p", lower=0, upper=1)
        sigma = pm.Uniform("sigma", lower=0, upper=5)
        eps_raw = pm.Normal("eps_raw", mu=0, sigma=1, shape=M)

        # Transformed parameters
        eps = pm.Deterministic("eps", pm.math.logit(mean_p) + sigma * eps_raw)

        # Likelihood using log_sum_exp for data augmentation
        # For individuals with y[i] > 0: z[i] = 1 (definitely present)
        # For individuals with y[i] = 0: z[i] could be 0 or 1
        
        # For observed individuals: bernoulli_lpmf(1 | omega) + binomial_logit_lpmf(y[i] | T, eps[i])
        logp_observed = (
            pm.logp(pm.Bernoulli.dist(p=omega), 1) +
            pm.logp(pm.Binomial.dist(n=T, logit_p=eps), y)
        )[observed_mask]
        
        # For unobserved individuals: log_sum_exp of two cases
        # Case 1: z[i] = 1, binomial_logit_lpmf(0 | T, eps[i]) 
        # Case 2: z[i] = 0
        logp_case1 = (
            pm.logp(pm.Bernoulli.dist(p=omega), 1) +
            pm.logp(pm.Binomial.dist(n=T, logit_p=eps), 0)
        )[unobserved_mask]
        
        logp_case2 = pm.logp(pm.Bernoulli.dist(p=omega), 0)
        
        # Use log_sum_exp for unobserved individuals
        logp_unobserved = pm.math.logsumexp(
            pt.stack([logp_case1, pt.full_like(logp_case1, logp_case2)], axis=0),
            axis=0
        )
        
        # Add likelihood contributions
        pm.Potential("likelihood_observed", pt.sum(logp_observed))
        pm.Potential("likelihood_unobserved", pt.sum(logp_unobserved))
        
    return model