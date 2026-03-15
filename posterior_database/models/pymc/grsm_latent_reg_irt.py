def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    I = data['I']  
    J = data['J']   
    N = data['N'] 
    ii = np.array(data['ii']) - 1  
    jj = np.array(data['jj']) - 1  
    y = np.array(data['y'])
    K = data['K']  
    W = np.array(data['W']).astype(float)
    
    # Obtain adjustments function  
    def obtain_adjustments(W_matrix):
        rows_W, cols_W = W_matrix.shape
        adj = np.zeros((2, cols_W))
        adj[0, 0] = 0.0  
        adj[1, 0] = 1.0  
        
        if cols_W > 1:
            for k in range(1, cols_W):  
                col_k = W_matrix[:, k]
                min_w = np.min(col_k)
                max_w = np.max(col_k)
                minmax_count = np.sum((col_k == min_w) | (col_k == max_w))
                
                if minmax_count == rows_W:
                    adj[0, k] = np.mean(col_k)  
                    adj[1, k] = max_w - min_w if max_w != min_w else 1.0     
                else:
                    adj[0, k] = np.mean(col_k)
                    std_val = np.std(col_k, ddof=0)
                    adj[1, k] = std_val * 2 if std_val > 0 else 1.0
        
        return adj
    
    m = int(np.max(y))  
    adj = obtain_adjustments(W)
    
    # Center and scale covariates
    W_adj = np.zeros_like(W)
    for k in range(K):
        if adj[1, k] != 0:
            W_adj[:, k] = (W[:, k] - adj[0, k]) / adj[1, k]
        else:
            W_adj[:, k] = W[:, k] - adj[0, k]
    
    with pm.Model() as model:
        # Parameters
        alpha = pm.LogNormal("alpha", mu=1.0, sigma=1.0, shape=I)
        
        beta_free = pm.Normal("beta_free", mu=0.0, sigma=3.0, shape=I-1)
        beta_sum = pt.sum(beta_free)
        beta_last = -beta_sum
        beta = pm.Deterministic("beta", pt.concatenate([beta_free, pt.stack([beta_last])]))
        
        kappa_free = pm.Normal("kappa_free", mu=0.0, sigma=3.0, shape=m-1)
        kappa_sum = pt.sum(kappa_free)
        kappa_last = -kappa_sum
        kappa = pm.Deterministic("kappa", pt.concatenate([kappa_free, pt.stack([kappa_last])]))
        
        # Try defining lambda_adj as scalar since K=1
        lambda_adj = pm.StudentT("lambda_adj", nu=3.0, mu=0.0, sigma=1.0)
        
        # For theta mean calculation with scalar lambda_adj and K=1
        theta_mean = W_adj[:, 0] * lambda_adj  # shape (J,)
        theta = pm.Normal("theta", mu=theta_mean, sigma=1.0, shape=J)
        
        # Add explicit priors for full beta and kappa vectors
        pm.Potential("beta_prior", pm.logp(pm.Normal.dist(mu=0.0, sigma=3.0), beta).sum())
        pm.Potential("kappa_prior", pm.logp(pm.Normal.dist(mu=0.0, sigma=3.0), kappa).sum())
        
        # RSM likelihood computation
        theta_indexed = theta[jj]
        alpha_indexed = alpha[ii] 
        beta_indexed = beta[ii]
        
        theta_alpha = theta_indexed * alpha_indexed
        
        # RSM implementation based on Stan function
        # Stan: unsummed = append_row(rep_vector(0, 1), theta - beta - kappa);
        # This creates a vector of length m+1: [0, theta-beta-kappa[0], ..., theta-beta-kappa[m-1]]
        
        # For each observation n:
        # unsummed[n] = [0, theta_alpha[n] - beta_indexed[n] - kappa[0], ..., theta_alpha[n] - beta_indexed[n] - kappa[m-1]]
        base_vals = theta_alpha - beta_indexed  # shape (N,)
        diff_matrix = base_vals[:, None] - kappa[None, :]  # shape (N, m)
        
        # Prepend zeros
        zeros_column = pt.zeros((N, 1))
        unsummed_matrix = pt.concatenate([zeros_column, diff_matrix], axis=1)  # shape (N, m+1)
        
        # Stan: probs = softmax(cumulative_sum(unsummed));
        cumsum_matrix = pt.cumsum(unsummed_matrix, axis=1)
        probs_matrix = pm.math.softmax(cumsum_matrix, axis=1)  # shape (N, m+1)
        
        # Stan: return categorical_lpmf(y + 1 | probs);
        # Here's the key insight: in Stan, y is 0-based but categorical_lpmf expects 1-based indices
        # So y=0 maps to category 1, y=1 maps to category 2, etc.
        # In PyMC, array indexing is 0-based, so:
        # y=0 should select probs_matrix[n, 0], y=1 should select probs_matrix[n, 1], etc.
        
        # The RSM function expects y to be in {0, 1, ..., m}, which maps to categories {1, 2, ..., m+1}
        # So the probs_matrix should have m+1 columns corresponding to these categories
        
        # Use y directly as 0-based indices into probs_matrix
        row_idx = pt.arange(N)
        y_tensor = pt.as_tensor_variable(y)  # keep y as 0-based for array indexing
        selected_probs = probs_matrix[row_idx, y_tensor]
        
        # Sum log probabilities
        total_log_prob = pt.sum(pt.log(selected_probs))
        pm.Potential("rsm_likelihood", total_log_prob)
    
    return model