def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    nmax = data['nmax']
    m = data['m'] 
    k = data['k']
    
    # Transformed data
    nmin = np.max(k)  # Minimal possible n
    n_values = np.arange(1, nmax + 1)  # n from 1 to nmax
    log_prior = np.log(1.0 / nmax)

    with pm.Model() as model:
        # Parameters
        theta = pm.Uniform("theta", lower=0, upper=1)

        # Transformed parameters - compute log probability for each possible n
        # This replicates the Stan lp_parts computation
        
        # For n < nmin, probability is zero (log prob = -inf)
        # For n >= nmin, compute log(1/nmax) + binomial_lpmf(k | n, theta)
        
        # Create log probabilities for each n
        lp_parts = []
        for n in n_values:
            if n < nmin:
                # Zero probability case - use large negative number instead of -inf
                lp_part = -1e10
            else:
                # Compute log(1/nmax) + sum of binomial log pmf for each observation
                # Manually compute binomial log pmf: log(binom(n,k)) + k*log(theta) + (n-k)*log(1-theta)
                log_likelihood = 0.0
                for ki in k:
                    # Binomial log pmf
                    log_binom_coeff = pt.gammaln(n + 1) - pt.gammaln(ki + 1) - pt.gammaln(n - ki + 1)
                    log_pmf = log_binom_coeff + ki * pt.log(theta) + (n - ki) * pt.log(1 - theta)
                    log_likelihood = log_likelihood + log_pmf
                    
                lp_part = log_prior + log_likelihood
            lp_parts.append(lp_part)
        
        # Stack the log probabilities
        lp_parts_tensor = pt.stack(lp_parts)
        
        # Add the log_sum_exp to target (this is the mixture marginalization)
        pm.Potential("mixture_logp", pm.math.logsumexp(lp_parts_tensor))
    
    return model