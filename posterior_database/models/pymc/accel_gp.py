def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data and ensure they're numpy arrays
    N = int(data['N'])
    Y = np.array(data['Y'])

    # GP 1 data
    Kgp_1 = int(data['Kgp_1'])
    Dgp_1 = int(data['Dgp_1'])
    NBgp_1 = int(data['NBgp_1'])
    Xgp_1 = np.array(data['Xgp_1'])
    slambda_1 = np.array(data['slambda_1'])  # shape [40, 1]

    # GP sigma data
    Kgp_sigma_1 = int(data['Kgp_sigma_1'])
    Dgp_sigma_1 = int(data['Dgp_sigma_1'])
    NBgp_sigma_1 = int(data['NBgp_sigma_1'])
    Xgp_sigma_1 = np.array(data['Xgp_sigma_1'])
    slambda_sigma_1 = np.array(data['slambda_sigma_1'])  # shape [20, 1]

    prior_only = int(data['prior_only'])

    with pm.Model() as model:
        # Helper function for spectral density - 1D isotropic case
        def spd_cov_exp_quad(slambda_arr, sdgp, lscale, D):
            # slambda_arr is numpy array of shape [NBgp, D]
            # For 1D case (Dls == 1) as in Stan
            constant = sdgp**2 * (pt.sqrt(2 * np.pi) * lscale)**D
            neg_half_lscale2 = -0.5 * lscale**2
            # dot_self(x[m]) equivalent to sum of squares for each row
            dot_self_vals = pt.sum(pt.as_tensor(slambda_arr)**2, axis=1)
            return constant * pt.exp(neg_half_lscale2 * dot_self_vals)
        
        # Parameters
        Intercept = pm.StudentT("Intercept", nu=3, mu=-13, sigma=36)
        
        # For truncated Student-t at 0, use TruncatedNormal to match constraint
        # Stan: student_t_lpdf(vsdgp_1 | 3, 0, 36) - 1 * student_t_lccdf(0 | 3, 0, 36)
        # This is exactly a truncated student-t distribution
        sdgp_1 = pm.TruncatedNormal("sdgp_1", mu=0, sigma=36, lower=0)
        
        lscale_1 = pm.InverseGamma("lscale_1", alpha=1.124909, beta=0.0177)
        
        zgp_1 = pm.Normal("zgp_1", mu=0, sigma=1, shape=NBgp_1)
        
        # GP sigma parameters  
        Intercept_sigma = pm.StudentT("Intercept_sigma", nu=3, mu=0, sigma=10)
        
        sdgp_sigma_1 = pm.TruncatedNormal("sdgp_sigma_1", mu=0, sigma=36, lower=0)
        
        lscale_sigma_1 = pm.InverseGamma("lscale_sigma_1", alpha=1.124909, beta=0.0177)
        
        zgp_sigma_1 = pm.Normal("zgp_sigma_1", mu=0, sigma=1, shape=NBgp_sigma_1)
        
        # Custom potentials to match Stan's exact truncated Student-t implementation
        # Stan uses: student_t_lpdf(vsdgp_1 | 3, 0, 36) - 1 * student_t_lccdf(0 | 3, 0, 36)
        # We need to replace TruncatedNormal's logp with truncated Student-t logp
        
        # Remove TruncatedNormal logp contribution and add truncated Student-t logp
        truncnorm_dist_1 = pm.TruncatedNormal.dist(mu=0, sigma=36, lower=0)
        truncnorm_dist_sigma = pm.TruncatedNormal.dist(mu=0, sigma=36, lower=0)
        
        # Add proper Student-t truncated logp
        st_dist = pm.StudentT.dist(nu=3, mu=0, sigma=36)
        st_logp_1 = pm.logp(st_dist, sdgp_1)
        st_logp_sigma = pm.logp(st_dist, sdgp_sigma_1)
        st_lccdf_0 = pm.logcdf(st_dist, 0)
        
        # Correct the distribution: remove TruncatedNormal logp, add truncated StudentT logp  
        pm.Potential("sdgp_1_correction", -pm.logp(truncnorm_dist_1, sdgp_1) + st_logp_1 - st_lccdf_0)
        pm.Potential("sdgp_sigma_1_correction", -pm.logp(truncnorm_dist_sigma, sdgp_sigma_1) + st_logp_sigma - st_lccdf_0)
        
        # GP approximation function (gpa)
        # For GP 1
        diag_spd_1 = pt.sqrt(spd_cov_exp_quad(slambda_1, sdgp_1, lscale_1, Dgp_1))
        gp_1 = pt.dot(Xgp_1, diag_spd_1 * zgp_1)
        
        # For GP sigma  
        diag_spd_sigma = pt.sqrt(spd_cov_exp_quad(slambda_sigma_1, sdgp_sigma_1, lscale_sigma_1, Dgp_sigma_1))
        gp_sigma = pt.dot(Xgp_sigma_1, diag_spd_sigma * zgp_sigma_1)
        
        # Linear predictors - match Stan exactly
        mu = pm.Deterministic("mu", Intercept + pt.zeros(N) + gp_1)
        log_sigma = pm.Deterministic("log_sigma", Intercept_sigma + pt.zeros(N) + gp_sigma)
        sigma = pm.Deterministic("sigma", pt.exp(log_sigma))
        
        # Likelihood
        if prior_only == 0:
            Y_obs = pm.Normal("Y", mu=mu, sigma=sigma, observed=Y)
        
        # Generated quantities
        b_Intercept = pm.Deterministic("b_Intercept", Intercept)
        b_sigma_Intercept = pm.Deterministic("b_sigma_Intercept", Intercept_sigma)

    return model