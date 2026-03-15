def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    with pm.Model() as model:
        # Parameter: theta with bounds [0, 1]
        # Stan: real<lower=0, upper=1> theta with beta(1, 1) prior
        theta = pm.Uniform("theta", lower=0.0, upper=1.0)
        
        # Likelihood: binomial observations using manual log probability
        # Let's compute the binomial log probability manually
        n1, n2 = data["n1"], data["n2"]
        k1, k2 = data["k1"], data["k2"]
        
        # Binomial log probability: log(C(n,k)) + k*log(p) + (n-k)*log(1-p)
        # PyMC might be dropping the binomial coefficient
        logp_k1 = k1 * pt.log(theta) + (n1 - k1) * pt.log(1 - theta)
        logp_k2 = k2 * pt.log(theta) + (n2 - k2) * pt.log(1 - theta)
        
        pm.Potential("likelihood", logp_k1 + logp_k2)

    return model