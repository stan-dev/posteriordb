def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data and ensure they are numpy arrays
    nyears = data['nyears']
    C = np.array(data['C'])
    N = np.array(data['N'])
    year = np.array(data['year'])
    
    # Transformed data (compute year_squared)
    year_squared = year * year
    
    with pm.Model() as model:
        # Parameters with priors
        alpha = pm.Normal("alpha", mu=0, sigma=100)
        beta1 = pm.Normal("beta1", mu=0, sigma=100)
        beta2 = pm.Normal("beta2", mu=0, sigma=100)
        
        # Transformed parameters (linear predictor)
        logit_p = alpha + beta1 * year + beta2 * year_squared
        
        # Likelihood - binomial with logit parameterization
        C_obs = pm.Binomial("C", n=N, logit_p=logit_p, observed=C)
        
        # PyMC excludes binomial coefficients, but Stan includes them
        # Need to subtract them to match Stan: -log(choose(N,C))
        log_binom_coeff = (
            pt.sum(pt.gammaln(N + 1)) - 
            pt.sum(pt.gammaln(C + 1)) - 
            pt.sum(pt.gammaln(N - C + 1))
        )
        pm.Potential("binom_coeff", -log_binom_coeff)
        
        # Generated quantities (deterministic transformation)
        p = pm.Deterministic("p", pm.math.invlogit(logit_p))
    
    return model