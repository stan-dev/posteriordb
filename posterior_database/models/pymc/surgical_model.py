def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    from pytensor.tensor import gammaln
    
    N = data['N']
    n = data['n']
    r = data['r']
    
    with pm.Model() as model:
        # Use Flat priors and implement everything via Potential
        mu = pm.Flat("mu")
        sigmasq = pm.HalfFlat("sigmasq")  # positive constraint
        b = pm.Flat("b", shape=N)
        
        # Transformed parameters
        sigma = pm.Deterministic("sigma", pt.sqrt(sigmasq))
        p = pm.Deterministic("p", pm.math.invlogit(b))
        
        # Prior for mu: normal(0, 1000)
        mu_logp = -0.5 * (mu / 1000.0)**2  # omitting constant terms
        pm.Potential("mu_prior", mu_logp)
        
        # Prior for sigmasq: inv_gamma(0.001, 0.001)
        alpha = 0.001
        beta = 0.001
        sigmasq_logp = (alpha - 1) * pt.log(sigmasq) - beta / sigmasq
        pm.Potential("sigmasq_prior", sigmasq_logp)
        
        # Prior for b: normal(mu, sigma)
        b_logp = pt.sum(-0.5 * ((b - mu) / sigma)**2)  # omitting constant terms
        pm.Potential("b_prior", b_logp)
        
        # Likelihood: r ~ binomial_logit(n, b)
        # binomial logit likelihood: r*log_inv_logit(b) + (n-r)*log(1-inv_logit(b))
        # = r*b - n*log1p(exp(b))  (more numerically stable form)
        lik_logp = pt.sum(r * b - n * pt.log1p(pt.exp(b)))
        pm.Potential("likelihood", lik_logp)
        
        # Generated quantity
        pop_mean = pm.Deterministic("pop_mean", pm.math.invlogit(mu))
        
    return model