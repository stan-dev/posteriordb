def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    J = data['J']  # sites within region
    K = data['K']  # visits to sites
    n = data['n']  # observed species
    X = np.array(data['X'])  # visits when species i was detected at site j
    S = data['S']  # superpopulation size

    # Precompute numpy arrays for likelihood
    X_arr = np.array(X)  # shape (n, J)
    detected_mask = X_arr > 0  # shape (n, J), numpy boolean

    with pm.Model() as model:
        # Parameters
        alpha = pm.Cauchy("alpha", alpha=0, beta=2.5)  # site-level occupancy
        beta = pm.Cauchy("beta", alpha=0, beta=2.5)   # site-level detection
        Omega = pm.Beta("Omega", alpha=2, beta=2)     # availability of species
        
        # Correlation parameter with special prior: (rho_uv + 1)/2 ~ beta(2, 2)
        rho_uv_scaled = pm.Beta("rho_uv_scaled", alpha=2, beta=2)
        rho_uv = pm.Deterministic("rho_uv", 2 * rho_uv_scaled - 1)
        
        # Scale parameters
        sigma_uv = pm.HalfCauchy("sigma_uv", beta=2.5, shape=2)
        
        # Species-level random effects 
        # Stan declares these as vector[S] uv1, vector[S] uv2, then applies MVN structure
        uv1 = pm.Normal("uv1", mu=0, sigma=1, shape=S)
        uv2 = pm.Normal("uv2", mu=0, sigma=1, shape=S)
        
        # Apply multivariate normal structure via potential (vectorized over S species)
        # Stan: target += multi_normal_lpdf(uv | rep_vector(0, 2), cov_matrix_2d(sigma_uv, rho_uv))

        # Stack into matrix: shape (S, 2)
        uv = pt.stack([uv1, uv2], axis=1)

        # Build covariance matrix
        var1 = sigma_uv[0]**2
        var2 = sigma_uv[1]**2
        cov12 = rho_uv * sigma_uv[0] * sigma_uv[1]
        cov_matrix = pt.stack([pt.stack([var1, cov12]), pt.stack([cov12, var2])])

        # Vectorized MVN logp for all species
        inv_cov = pt.linalg.solve(cov_matrix, pt.eye(2))
        det_cov = var1 * var2 - cov12**2
        quad_forms = pt.sum(uv @ inv_cov * uv, axis=1)  # shape (S,)
        mvn_logp = -0.5 * pt.sum(quad_forms) - 0.5 * S * pt.log(det_cov) - S * np.log(2 * np.pi)

        # Subtract already-counted standard normal densities
        std_normal_logp = -0.5 * pt.sum(uv1**2) - 0.5 * pt.sum(uv2**2) - S * np.log(2 * np.pi)
        mvn_potential = mvn_logp - std_normal_logp
        pm.Potential("mvn_structure", mvn_potential)
        
        # Transformed parameters - match Stan exactly
        logit_psi = uv1 + alpha  # Stan: logit_psi[i] = uv[i, 1] + alpha
        logit_theta = uv2 + beta  # Stan: logit_theta[i] = uv[i, 2] + beta
        
        # Likelihood components (vectorized)

        # --- Observed species likelihood (vectorized over n species and J sites) ---

        logit_psi_obs = logit_psi[:n]    # shape (n,)
        logit_theta_obs = logit_theta[:n]  # shape (n,)

        log_psi = logit_psi_obs - pt.log1p(pt.exp(logit_psi_obs))   # log_inv_logit
        log1m_psi = -pt.log1p(pt.exp(logit_psi_obs))                # log1m_inv_logit

        # Binomial logit lpmf for all (species, site) pairs: shape (n, J)
        X_float = pt.as_tensor_variable(X_arr.astype(np.float64))
        binom_lpmf = (X_float * logit_theta_obs[:, None]
                      - K * pt.log1p(pt.exp(logit_theta_obs[:, None]))
                      + pt.gammaln(K + 1) - pt.gammaln(X_float + 1)
                      - pt.gammaln(K - X_float + 1))

        # lp for sites where species was detected
        lp_detected = log_psi[:, None] + binom_lpmf  # shape (n, J)

        # lp for sites where species was NOT detected: logaddexp(lp_observed(0,...), log1m_psi)
        binom_0 = -K * pt.log1p(pt.exp(logit_theta_obs[:, None]))  # binom(0|K,logit_p)
        # gammaln(K+1) - gammaln(1) - gammaln(K+1) = 0, so binom coeff for x=0 vanishes
        lp_unobs_present = log_psi[:, None] + binom_0
        lp_unobs_absent = log1m_psi[:, None]
        lp_not_detected = pm.math.logaddexp(lp_unobs_present, lp_unobs_absent)

        # Select based on detection mask
        lp_sites = pt.where(detected_mask, lp_detected, lp_not_detected)
        logp_observed_species = n * pt.log(Omega) + pt.sum(lp_sites)

        # --- Unobserved species likelihood (vectorized over S-n species) ---
        logit_psi_unobs = logit_psi[n:]      # shape (S-n,)
        logit_theta_unobs = logit_theta[n:]   # shape (S-n,)

        log_psi_u = logit_psi_unobs - pt.log1p(pt.exp(logit_psi_unobs))
        log1m_psi_u = -pt.log1p(pt.exp(logit_psi_unobs))
        binom_0_u = -K * pt.log1p(pt.exp(logit_theta_unobs))
        lp_unobs_u = pm.math.logaddexp(log_psi_u + binom_0_u, log1m_psi_u)  # per species

        lp_unavailable = pt.log(1 - Omega)
        lp_available = pt.log(Omega) + J * lp_unobs_u
        logp_unobserved_species = pt.sum(pm.math.logaddexp(lp_unavailable, lp_available))

        total_logp = logp_observed_species + logp_unobserved_species
        pm.Potential("likelihood", total_logp)
        
    
    return model