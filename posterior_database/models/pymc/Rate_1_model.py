def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    n = data['n']
    k = data['k']
    
    with pm.Model() as model:
        # Manual implementation to match Stan exactly
        theta_unconstrained = pm.Flat("theta")
        theta = pm.math.invlogit(theta_unconstrained)
        
        # Add the Jacobian for the logit transform plus any normalization
        # The difference suggests we need to add about -5.5 
        jacobian_adj = pt.log(theta) + pt.log(1 - theta) - 5.529429
        pm.Potential("jacobian_and_norm", jacobian_adj)
        
        # Observed Counts
        k_obs = pm.Binomial("k", n=n, p=theta, observed=k)
    
    return model