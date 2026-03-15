def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    I = data['I']  # number of items
    J = data['J']  # number of persons 
    N = data['N']  # number of observations
    ii = np.array(data['ii']) - 1  # item indices (convert to 0-based)
    jj = np.array(data['jj']) - 1  # person indices (convert to 0-based)
    y = np.array(data['y'])  # responses
    
    with pm.Model() as model:
        # Person abilities
        theta = pm.Normal("theta", mu=0, sigma=1, shape=J)
        
        # Item parameters as separate vectors (matching Stan structure)
        xi1 = pm.Normal("xi1", mu=0, sigma=1, shape=I) 
        xi2 = pm.Normal("xi2", mu=0, sigma=1, shape=I)
        
        # Hyperparameters 
        mu = pm.Normal("mu", mu=np.array([0., 0.]), sigma=np.array([1., 5.]), shape=2)
        tau = pm.Exponential("tau", lam=0.1, shape=2)
        
        # L_Omega: For 2x2, this is just one free parameter (scalar)
        L_Omega = pm.Normal("L_Omega", mu=0, sigma=1)  # Single scalar parameter
        
        # Construct 2x2 Cholesky factor from the single parameter
        # L_Omega = [[1, 0], [tanh(L_Omega), sqrt(1 - tanh(L_Omega)^2)]]
        rho = pt.tanh(L_Omega)
        L_chol = pt.stack([
            pt.stack([1., 0.]),
            pt.stack([rho, pt.sqrt(1. - rho**2)])
        ])
        
        # Apply LKJ Jacobian manually 
        # For 2x2 case: log Jacobian = (eta-1) * log(1-rho^2) = (4-1) * log(1-rho^2) 
        # Plus the tanh Jacobian: log(1-tanh^2(x))
        lkj_jacobian = 3. * pt.log(1. - rho**2)
        tanh_jacobian = pt.log(1. - pt.tanh(L_Omega)**2)
        pm.Potential("lkj_prior", lkj_jacobian + tanh_jacobian)
        
        # Construct L_Sigma = diag_pre_multiply(tau, L_Omega)
        L_Sigma = pt.diag(tau) @ L_chol
        
        # Stack xi parameters for MVN
        xi_combined = pt.stack([xi1, xi2], axis=1)  # Shape: (I, 2)
        
        # Apply MVN constraint (vectorized over all items)
        pm.Potential("xi_mvn_constraint",
                    pm.logp(pm.MvNormal.dist(mu=mu, chol=L_Sigma), xi_combined).sum())
        
        # Transformed parameters
        alpha = pm.Deterministic("alpha", pt.exp(xi1))
        beta = pm.Deterministic("beta", xi2)
        
        # Likelihood
        logit_p = alpha[ii] * (theta[jj] - beta[ii])
        pm.Bernoulli("y", logit_p=logit_p, observed=y)
        
        # Generated quantities 
        Omega = pm.Deterministic("Omega", L_chol @ L_chol.T)
    
    return model