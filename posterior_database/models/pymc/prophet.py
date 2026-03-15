def make_model(data: dict):
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    # Extract data
    T = data['T']
    K = data['K']
    t = data['t']
    cap = data['cap']
    y = data['y']
    S = data['S']
    t_change = data['t_change']
    X = data['X']
    sigmas = data['sigmas']
    tau = data['tau']
    trend_indicator = data['trend_indicator']
    s_a = data['s_a']
    s_m = data['s_m']
    
    def get_changepoint_matrix(t, t_change, T, S):
        """
        Compute the changepoint matrix A[T, S].
        A[i, j] = 1 if t[i] >= t_change[j], 0 otherwise.
        """
        return (np.asarray(t)[:, None] >= np.asarray(t_change)[None, :]).astype(float)
    
    def logistic_gamma(k, m, delta, t_change, S):
        """
        Compute adjusted offsets for piecewise logistic trend continuity.
        Uses pytensor.scan since each step depends on the previous m value.
        """
        import pytensor

        # Compute the rate in each segment
        k_s = pt.concatenate([pt.atleast_1d(k), k + pt.cumsum(delta)])

        def gamma_step(tc_i, k_i, k_ip1, m_prev):
            gamma_i = (tc_i - m_prev) * (1 - k_i / k_ip1)
            return gamma_i, m_prev + gamma_i

        (gammas, _), _ = pytensor.scan(
            fn=gamma_step,
            sequences=[pt.as_tensor_variable(t_change), k_s[:-1], k_s[1:]],
            outputs_info=[None, m],
        )
        return gammas
    
    def logistic_trend(k, m, delta, t, cap, A, t_change, S):
        """
        Compute logistic trend.
        """
        gamma = logistic_gamma(k, m, delta, t_change, S)
        rate = k + pt.dot(A, delta)
        offset = m + pt.dot(A, gamma)
        return cap * pm.math.invlogit(rate * (t - offset))
    
    def linear_trend(k, m, delta, t, A, t_change):
        """
        Compute linear trend.
        """
        rate = k + pt.dot(A, delta)
        offset = m + pt.dot(A, -pt.as_tensor(t_change) * delta)
        return rate * t + offset
    
    # Transformed data
    A = get_changepoint_matrix(t, t_change, T, S)
    
    with pm.Model() as model:
        # Parameters
        k = pm.Normal("k", mu=0, sigma=5)
        m = pm.Normal("m", mu=0, sigma=5)
        delta = pm.Laplace("delta", mu=0, b=tau, shape=S)
        sigma_obs = pm.HalfNormal("sigma_obs", sigma=0.5)
        beta = pm.Normal("beta", mu=0, sigma=sigmas, shape=K)
        
        # Correct for HalfNormal log(2) offset to match Stan
        pm.Potential("half_dist_correction", -pt.log(2.0))
        
        # Compute trend based on trend_indicator
        if trend_indicator == 0:  # Linear trend
            trend = linear_trend(k, m, delta, t, A, t_change)
        else:  # Logistic trend
            trend = logistic_trend(k, m, delta, t, cap, A, t_change, S)
        
        # Compute mean with additive and multiplicative components
        additive_comp = pt.dot(X, beta * s_a)
        multiplicative_comp = pt.dot(X, beta * s_m)
        mu = trend * (1 + multiplicative_comp) + additive_comp
        
        # Likelihood
        y_obs = pm.Normal("y", mu=mu, sigma=sigma_obs, observed=y)
    
    return model