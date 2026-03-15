def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    N_data = data['N']
    N_states = data['N_states']
    N_regions = data['N_regions']
    N_years_obs = data['N_years_obs']
    N_years = data['N_years']
    state_region_ind = np.array(data['state_region_ind']) - 1  # 1->0 based
    state_ind = np.array(data['state_ind']) - 1
    region_ind = np.array(data['region_ind']) - 1
    year_ind = np.array(data['year_ind']) - 1
    y_data = np.array(data['y'], dtype=float)

    # Transformed data
    years = np.arange(1, N_years + 1, dtype=float)
    counts = 2.0 * np.ones(17)

    # Squared distance matrix for GP covariance
    years_col = years[:, None]
    sq_dist = (years_col - years_col.T) ** 2  # (N_years, N_years)

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
        # Parameters (match Stan declaration order)
        # Stan: matrix[N_years, N_regions] GP_region_std - column-major
        GP_region_std_flat = pm.Normal("GP_region_std_flat", mu=0, sigma=1,
                                       shape=N_years * N_regions)
        # Stan: matrix[N_years, N_states] GP_state_std - column-major
        GP_state_std_flat = pm.Normal("GP_state_std_flat", mu=0, sigma=1,
                                      shape=N_years * N_states)
        year_std = pm.Normal("year_std", mu=0, sigma=1, shape=N_years_obs)
        state_std = pm.Normal("state_std", mu=0, sigma=1, shape=N_states)
        region_std = pm.Normal("region_std", mu=0, sigma=1, shape=N_regions)

        tot_var = pm.Gamma("tot_var", alpha=3, beta=3)

        # prop_var: simplex[17] with Dirichlet(counts) prior
        prop_var_raw = pm.Flat("prop_var_raw", shape=16)

        mu = pm.Normal("mu", mu=0.5, sigma=0.5)

        length_GP_region_long = pm.Weibull("length_GP_region_long", alpha=30, beta=8)
        length_GP_state_long = pm.Weibull("length_GP_state_long", alpha=30, beta=8)
        length_GP_region_short = pm.Weibull("length_GP_region_short", alpha=30, beta=3)
        length_GP_state_short = pm.Weibull("length_GP_state_short", alpha=30, beta=3)

        # Transform prop_var and add prior + Jacobian
        prop_var = _stan_simplex(prop_var_raw, 17)
        pm.Potential("prop_var_lp", _stan_simplex_logp(prop_var, 17, counts))

        # Transformed parameters
        vars_17 = 17 * prop_var * tot_var
        sigma_year = pt.sqrt(vars_17[0])
        sigma_region = pt.sqrt(vars_17[1])
        sigma_state = pt.sqrt(vars_17[2:12])  # 10 elements for states
        sigma_GP_region_long = pt.sqrt(vars_17[12])
        sigma_GP_state_long = pt.sqrt(vars_17[13])
        sigma_GP_region_short = pt.sqrt(vars_17[14])
        sigma_GP_state_short = pt.sqrt(vars_17[15])
        sigma_error = pt.sqrt(vars_17[16])

        region_re = sigma_region * region_std
        year_re = sigma_year * year_std
        state_re = sigma_state[state_region_ind] * state_std

        # GP covariance matrices
        sq_dist_tensor = pt.as_tensor_variable(sq_dist)
        cov_region = (sigma_GP_region_long ** 2 * pt.exp(-sq_dist_tensor / (2 * length_GP_region_long ** 2)) +
                      sigma_GP_region_short ** 2 * pt.exp(-sq_dist_tensor / (2 * length_GP_region_short ** 2)))
        cov_state = (sigma_GP_state_long ** 2 * pt.exp(-sq_dist_tensor / (2 * length_GP_state_long ** 2)) +
                     sigma_GP_state_short ** 2 * pt.exp(-sq_dist_tensor / (2 * length_GP_state_short ** 2)))

        # Add jitter for numerical stability
        jitter = 1e-6 * pt.eye(N_years)
        cov_region = cov_region + jitter
        cov_state = cov_state + jitter

        # Cholesky decomposition
        L_cov_region = pt.linalg.cholesky(cov_region)
        L_cov_state = pt.linalg.cholesky(cov_state)

        # Reconstruct GP matrices from column-major flat representation
        GP_region_std_cols = [GP_region_std_flat[r * N_years:(r + 1) * N_years]
                              for r in range(N_regions)]
        GP_region_std = pt.stack(GP_region_std_cols, axis=1)  # (N_years, N_regions)

        GP_state_std_cols = [GP_state_std_flat[s * N_years:(s + 1) * N_years]
                             for s in range(N_states)]
        GP_state_std = pt.stack(GP_state_std_cols, axis=1)  # (N_years, N_states)

        # GP = L_cov @ GP_std
        GP_region = L_cov_region @ GP_region_std  # (N_years, N_regions)
        GP_state = L_cov_state @ GP_state_std  # (N_years, N_states)

        # Observation mean
        obs_mu = (mu + year_re[year_ind] + state_re[state_ind] +
                  region_re[region_ind] +
                  GP_region[year_ind, region_ind] +
                  GP_state[year_ind, state_ind])

        # Likelihood
        pm.Normal("y", mu=obs_mu, sigma=sigma_error, observed=y_data)

    return model
