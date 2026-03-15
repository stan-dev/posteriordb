def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import pytensor
    import numpy as np

    K = data['K']
    N = data['N']
    u = np.array(data['u'], dtype=float)
    v = np.array(data['v'], dtype=float)
    alpha = np.array(data['alpha'], dtype=float)  # (K, K)
    tau = float(data['tau'])
    rho = float(data['rho'])

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
        # Parameters (match Stan order: theta1, theta2, phi, lambda)
        theta1_raw = pm.Flat("theta1_raw", shape=K - 1)
        theta2_raw = pm.Flat("theta2_raw", shape=K - 1)

        # phi: ordered[K]
        phi = pm.Normal("phi", mu=0, sigma=10, shape=K,
                        transform=pm.distributions.transforms.ordered)
        # lambda: ordered[K]
        lambda_ = pm.Normal("lambda_", mu=0, sigma=10, shape=K,
                            transform=pm.distributions.transforms.ordered)

        # Transform simplices
        theta1 = _stan_simplex(theta1_raw, K)  # (K,)
        theta2 = _stan_simplex(theta2_raw, K)  # (K,)
        theta = pt.stack([theta1, theta2], axis=0)  # (K, K)

        # Dirichlet priors + Jacobians
        pm.Potential("theta1_lp", _stan_simplex_logp(theta1, K, alpha[0, :]))
        pm.Potential("theta2_lp", _stan_simplex_logp(theta2, K, alpha[1, :]))

        # Specific priors on phi and lambda (cancel default Normal(0,10))
        pm.Potential("phi_prior",
                     pm.logp(pm.Normal.dist(mu=0, sigma=1), phi[0]) +
                     pm.logp(pm.Normal.dist(mu=3, sigma=1), phi[1]))
        pm.Potential("phi_cancel",
                     -pm.logp(pm.Normal.dist(mu=0, sigma=10), phi).sum())

        pm.Potential("lambda_prior",
                     pm.logp(pm.Normal.dist(mu=0, sigma=1), lambda_[0]) +
                     pm.logp(pm.Normal.dist(mu=3, sigma=1), lambda_[1]))
        pm.Potential("lambda_cancel",
                     -pm.logp(pm.Normal.dist(mu=0, sigma=10), lambda_).sum())

        # Forward algorithm
        log_theta = pt.log(theta)

        def forward_step(u_t, v_t, gamma_prev, phi, lambda_, log_theta):
            emission = (pm.logp(pm.Normal.dist(mu=phi, sigma=tau), u_t) +
                        pm.logp(pm.Normal.dist(mu=lambda_, sigma=rho), v_t))  # (K,)
            acc = gamma_prev[:, None] + log_theta + emission[None, :]  # (K, K)
            return pt.logsumexp(acc, axis=0)  # (K,)

        # Initial step
        gamma_1 = (pm.logp(pm.Normal.dist(mu=phi, sigma=tau), u[0]) +
                   pm.logp(pm.Normal.dist(mu=lambda_, sigma=rho), v[0]))

        if N > 1:
            gamma_seq, _ = pytensor.scan(
                fn=forward_step,
                sequences=[pt.as_tensor_variable(u[1:]),
                           pt.as_tensor_variable(v[1:])],
                outputs_info=gamma_1,
                non_sequences=[phi, lambda_, log_theta],
            )
            final_gamma = gamma_seq[-1]
        else:
            final_gamma = gamma_1

        pm.Potential("forward_loglik", pt.logsumexp(final_gamma))

    return model
