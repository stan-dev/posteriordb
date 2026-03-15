def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    V = data['V']
    M = data['M']
    N = data['N']
    w = np.array(data['w']) - 1  # Convert 1-based to 0-based
    doc = np.array(data['doc']) - 1  # Convert 1-based to 0-based
    alpha = np.array(data['alpha'])
    beta = np.array(data['beta'])

    K = 5

    def _build_helmert(dim):
        """Helmert sub-matrix (dim, dim-1) for Stan's ILR simplex transform."""
        H = np.zeros((dim, dim - 1))
        for j in range(dim - 1):
            s = 1.0 / np.sqrt((j + 1) * (j + 2))
            H[:j + 1, j] = s
            H[j + 1, j] = -(j + 1) * s
        return H

    def _stan_simplex(y_raw, dim):
        """Stan's ILR+softmax simplex: unconstrained (..., dim-1) -> simplex (..., dim)."""
        H = pt.as_tensor_variable(_build_helmert(dim))
        z = y_raw @ H.T
        return pm.math.softmax(z, axis=-1)

    def _stan_simplex_logp(x, dim, conc):
        """Dirichlet(conc) logp (unnormalized) + ILR Jacobian."""
        logp = pt.sum((pt.as_tensor_variable(conc) - 1) * pt.log(x), axis=-1)
        jac = pt.sum(pt.log(x), axis=-1) + 0.5 * np.log(dim)
        return pt.sum(logp + jac)

    with pm.Model() as model:
        # Parameters - Stan order: theta[M] (array[M] simplex[K]), phi[K] (array[K] simplex[V])
        theta_raw = pm.Flat("theta_raw", shape=M * (K - 1))
        phi_raw = pm.Flat("phi_raw", shape=K * (V - 1))

        # Contiguous reshape (Stan lays out array elements contiguously in unconstrained space)
        theta_raw_2d = theta_raw.reshape((M, K - 1))  # (M, K-1)
        phi_raw_2d = phi_raw.reshape((K, V - 1))  # (K, V-1)
        theta = _stan_simplex(theta_raw_2d, K)  # (M, K)
        phi = _stan_simplex(phi_raw_2d, V)  # (K, V)

        # Dirichlet priors + Jacobians
        pm.Potential("theta_lp", _stan_simplex_logp(theta, K, alpha))
        pm.Potential("phi_lp", _stan_simplex_logp(phi, V, beta))

        # Marginalized likelihood: for each word token, sum over topics
        log_theta_doc = pt.log(theta[doc, :])  # (N, K)
        log_phi_word = pt.log(phi[:, w]).T      # (N, K)
        log_lik = pt.logsumexp(log_theta_doc + log_phi_word, axis=1)
        pm.Potential("log_lik", pt.sum(log_lik))

    return model
