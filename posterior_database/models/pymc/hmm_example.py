def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import pytensor
    import numpy as np
    
    N = data['N']
    K = data['K']  # K = 2
    y_data = data['y']
    
    with pm.Model() as model:
        # For a 2-simplex, we have 1 unconstrained parameter (logit scale)
        # Use the same parameterization as Stan
        theta1_raw = pm.Flat("theta1_raw")
        theta2_raw = pm.Flat("theta2_raw")
        
        # Transform to simplex using softmax (stick-breaking for 2D case)
        # For 2D simplex: [p1, p2] where p1 + p2 = 1
        # We use logit parameterization: p1 = sigmoid(theta_raw), p2 = 1 - p1
        theta1 = pt.stack([pm.math.sigmoid(theta1_raw), 1 - pm.math.sigmoid(theta1_raw)])
        theta2 = pt.stack([pm.math.sigmoid(theta2_raw), 1 - pm.math.sigmoid(theta2_raw)])
        
        # Add Jacobian for simplex transform (logit-link Jacobian)
        pm.Potential("theta1_jacobian", pt.log(theta1[0]) + pt.log(theta1[1]))
        pm.Potential("theta2_jacobian", pt.log(theta2[0]) + pt.log(theta2[1]))
        
        # Positive ordered means - 2 unconstrained parameters that get ordered
        mu_raw = pm.Flat("mu_raw", shape=K)
        # Transform to positive ordered: mu[0] = exp(mu_raw[0]), mu[1] = exp(mu_raw[0]) + exp(mu_raw[1])
        mu = pt.stack([pt.exp(mu_raw[0]), pt.exp(mu_raw[0]) + pt.exp(mu_raw[1])])
        
        # Add Jacobian for ordered transform
        pm.Potential("mu_jacobian", mu_raw[0] + mu_raw[1] + pt.log(2.0))
        
        # Transformed parameters - construct transition matrix
        theta = pt.stack([theta1, theta2], axis=0)  # shape (K, K)
        
        # Priors on mu (explicit in Stan model block)
        pm.Potential("mu_prior", 
                    pm.logp(pm.Normal.dist(mu=3, sigma=1), mu[0]) +
                    pm.logp(pm.Normal.dist(mu=10, sigma=1), mu[1]))
        
        # Forward algorithm using pytensor.scan
        def forward_step(y_t, gamma_prev, theta, mu):
            # gamma_prev has shape (K,)
            # Compute emission probabilities for current observation
            emission_logp = pm.logp(pm.Normal.dist(mu=mu, sigma=1), y_t)  # shape (K,)
            
            # For each current state k, compute log probability from all previous states
            log_theta = pt.log(theta)  # shape (K, K)
            
            # Vectorized computation: for each k, sum over j
            acc_matrix = gamma_prev[:, None] + log_theta + emission_logp[None, :]  # (K, K)
            gamma_t = pt.logsumexp(acc_matrix, axis=0)  # shape (K,)
            
            return gamma_t
        
        # Initial state probabilities (emission probabilities for first observation)
        gamma_1 = pm.logp(pm.Normal.dist(mu=mu, sigma=1), y_data[0])  # shape (K,)
        
        # Run forward algorithm for remaining observations
        if N > 1:
            gamma_seq, _ = pytensor.scan(
                fn=forward_step,
                sequences=pt.as_tensor_variable(y_data[1:]),
                outputs_info=gamma_1,
                non_sequences=[theta, mu],
                strict=True
            )
            # gamma_seq has shape (N-1, K)
            final_gamma = gamma_seq[-1]
        else:
            final_gamma = gamma_1
            
        # Add likelihood
        pm.Potential("likelihood", pt.logsumexp(final_gamma))
    
    return model