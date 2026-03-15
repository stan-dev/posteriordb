def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    import pytensor
    
    # Extract data
    K = data['K']
    N = data['N']
    u = np.array(data['u'])
    v = np.array(data['v'])
    alpha = np.array(data['alpha'])
    
    with pm.Model() as model:
        # For K=2 simplex, we need only K-1=1 unconstrained parameters
        # Use the stick-breaking parameterization manually
        theta1_raw = pm.Normal("theta1_raw", mu=0, sigma=1)  # scalar for K=2
        theta2_raw = pm.Normal("theta2_raw", mu=0, sigma=1)  # scalar for K=2
        
        # Transform to simplex using logistic function for K=2 case
        theta1_0 = pm.math.invlogit(theta1_raw)
        theta1_1 = 1 - theta1_0
        theta1 = pt.stack([theta1_0, theta1_1])
        
        theta2_0 = pm.math.invlogit(theta2_raw)
        theta2_1 = 1 - theta2_0
        theta2 = pt.stack([theta2_0, theta2_1])
        
        # Apply Dirichlet priors
        pm.Potential("theta1_prior", pm.logp(pm.Dirichlet.dist(a=alpha[0, :]), theta1))
        pm.Potential("theta2_prior", pm.logp(pm.Dirichlet.dist(a=alpha[1, :]), theta2))
        
        # Cancel default priors
        pm.Potential("theta1_cancel", -pm.logp(pm.Normal.dist(mu=0, sigma=1), theta1_raw))
        pm.Potential("theta2_cancel", -pm.logp(pm.Normal.dist(mu=0, sigma=1), theta2_raw))
        
        # Add Jacobian for stick-breaking transform
        pm.Potential("theta1_jacobian", pt.log(theta1_0) + pt.log(theta1_1))
        pm.Potential("theta2_jacobian", pt.log(theta2_0) + pt.log(theta2_1))
        
        # Positive ordered parameters 
        phi_log = pm.Normal("phi_log", mu=0, sigma=1, shape=K, 
                           transform=pm.distributions.transforms.ordered)
        lambda_log = pm.Normal("lambda_log", mu=0, sigma=1, shape=K,
                              transform=pm.distributions.transforms.ordered)
        
        # Transform to positive scale
        phi = pm.Deterministic("phi", pt.exp(phi_log))
        lambda_ = pm.Deterministic("lambda", pt.exp(lambda_log))
        
        # Apply the specific priors from the Stan model on the log scale
        pm.Potential("phi_prior_1", pm.logp(pm.Normal.dist(mu=0, sigma=1), phi_log[0]))
        pm.Potential("phi_prior_2", pm.logp(pm.Normal.dist(mu=3, sigma=1), phi_log[1]))
        pm.Potential("lambda_prior_1", pm.logp(pm.Normal.dist(mu=0, sigma=1), lambda_log[0]))
        pm.Potential("lambda_prior_2", pm.logp(pm.Normal.dist(mu=3, sigma=1), lambda_log[1]))
        
        # Cancel out the default priors
        pm.Potential("phi_cancel", -pm.logp(pm.Normal.dist(mu=0, sigma=1), phi_log).sum())
        pm.Potential("lambda_cancel", -pm.logp(pm.Normal.dist(mu=0, sigma=1), lambda_log).sum())
        
        # Stack theta parameters for transition matrix
        theta = pt.stack([theta1, theta2])  # shape (K, K)
        
        # Forward algorithm implementation
        u_tensor = pt.as_tensor_variable(u)
        v_tensor = pt.as_tensor_variable(v)
        
        # Initialize first time step
        gamma_1 = pt.zeros(K)
        for k in range(K):
            emission_1 = (pm.logp(pm.Exponential.dist(lam=phi[k]), u_tensor[0]) + 
                         pm.logp(pm.Exponential.dist(lam=lambda_[k]), v_tensor[0]))
            gamma_1 = pt.set_subtensor(gamma_1[k], emission_1)
        
        # Forward step function
        def forward_step(t, gamma_prev, phi, lambda_, theta, u_arr, v_arr):
            gamma_t = pt.zeros(K)
            
            for k in range(K):
                # Emission log probability for state k at time t
                emission_logp = (pm.logp(pm.Exponential.dist(lam=phi[k]), u_arr[t]) + 
                               pm.logp(pm.Exponential.dist(lam=lambda_[k]), v_arr[t]))
                
                # Accumulate transitions from all states j to k
                acc = pt.zeros(K)
                for j in range(K):
                    acc = pt.set_subtensor(acc[j], 
                                          gamma_prev[j] + pt.log(theta[j, k]) + emission_logp)
                
                gamma_t = pt.set_subtensor(gamma_t[k], pm.math.logsumexp(acc))
            
            return gamma_t
        
        # Run forward algorithm
        if N > 1:
            t_indices = pt.arange(1, N)
            
            gamma_seq, _ = pytensor.scan(
                fn=forward_step,
                sequences=[t_indices],
                outputs_info=[gamma_1],
                non_sequences=[phi, lambda_, theta, u_tensor, v_tensor],
                n_steps=N-1
            )
            
            gamma_final = gamma_seq[-1]
        else:
            gamma_final = gamma_1
        
        # Add the log marginal likelihood
        pm.Potential("forward_loglik", pm.math.logsumexp(gamma_final))
    
    return model