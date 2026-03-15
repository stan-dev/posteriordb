def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    I = data['I']  # number of questions
    J = data['J']  # number of persons  
    N = data['N']  # number of observations
    ii = np.array(data['ii']) - 1  # convert to 0-based indexing
    jj = np.array(data['jj']) - 1  # convert to 0-based indexing
    y = np.array(data['y'])
    K = data['K']  # number of covariates
    W = np.array(data['W'], dtype=float)  # person covariate matrix
    
    # Implement obtain_adjustments function
    def obtain_adjustments(W):
        adj = np.zeros((2, K))
        adj[0, 0] = 0  # first column adjustment (Stan adj[1,1] = 0)
        adj[1, 0] = 1  # (Stan adj[2,1] = 1)
        
        if K > 1:
            for k in range(1, K):  # remaining columns (Stan k in 2:cols(W))
                col = W[:, k]
                min_w = np.min(col)
                max_w = np.max(col)
                
                # Count how many values are exactly min or max
                minmax_count = np.sum((col == min_w) | (col == max_w))
                
                if minmax_count == len(col):
                    # if column takes only 2 values
                    adj[0, k] = np.mean(col)  # adj[1, k] in Stan
                    adj[1, k] = max_w - min_w  # adj[2, k] in Stan
                else:
                    # if column takes > 2 values
                    adj[0, k] = np.mean(col)  # adj[1, k] in Stan
                    adj[1, k] = np.std(col) * 2  # adj[2, k] in Stan, using population std (ddof=0)
        
        return adj
    
    # Compute adjustments and transformed covariates
    adj = obtain_adjustments(W)
    W_adj = np.zeros_like(W, dtype=float)
    for k in range(K):
        for j in range(J):
            W_adj[j, k] = (W[j, k] - adj[0, k]) / adj[1, k]
    
    with pm.Model() as model:
        # Parameters
        alpha = pm.LogNormal("alpha", mu=1, sigma=1, shape=I)
        beta_free = pm.Normal("beta_free", mu=0, sigma=3, shape=I-1)
        lambda_adj = pm.StudentT("lambda_adj", nu=3, mu=0, sigma=1, shape=K)
        
        # Transformed parameters
        # beta[1:I-1] = beta_free, beta[I] = -sum(beta_free)
        beta = pt.concatenate([beta_free, pt.atleast_1d(-pt.sum(beta_free))])
        
        # theta ~ normal(W_adj * lambda_adj, 1)
        mu_theta = W_adj @ lambda_adj
        theta = pm.Normal("theta", mu=mu_theta, sigma=1, shape=J)
        
        # Likelihood
        logit_p = alpha[ii] * theta[jj] - beta[ii]
        pm.Bernoulli("y", logit_p=logit_p, observed=y)

    return model