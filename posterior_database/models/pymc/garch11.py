def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    T = data['T']
    y = data['y']
    sigma1 = data['sigma1']

    with pm.Model() as model:
        # Parameters
        mu = pm.Flat("mu")
        alpha0 = pm.HalfFlat("alpha0")
        alpha1 = pm.Uniform("alpha1", lower=0, upper=1)
        
        # beta1 has dependent bounds: 0 < beta1 < (1 - alpha1)
        # Use a helper variable and transform
        beta1_raw = pm.Uniform("beta1_raw", lower=0, upper=1)
        beta1 = pm.Deterministic("beta1", beta1_raw * (1 - alpha1))
        
        # Add Jacobian for the transform: log|d(beta1)/d(beta1_raw)| = log(1 - alpha1)
        pm.Potential("beta1_jacobian", pt.log(1 - alpha1))
        
        import pytensor

        # Build sigma array using scan for vectorized GARCH(1,1) computation
        def garch_step(y_prev, sigma_prev, alpha0, alpha1, beta1_val, mu):
            return pt.sqrt(alpha0 + alpha1 * (y_prev - mu)**2 + beta1_val * sigma_prev**2)

        y_tensor = pt.as_tensor_variable(y)
        sigma1_val = pt.as_tensor_variable(np.float64(sigma1))

        sigmas, _ = pytensor.scan(
            fn=garch_step,
            sequences=[y_tensor[:-1]],
            outputs_info=[sigma1_val],
            non_sequences=[alpha0, alpha1, beta1, mu],
        )
        sigma = pt.concatenate([pt.atleast_1d(sigma1_val), sigmas])
        sigma = pm.Deterministic("sigma", sigma)
        
        # Likelihood
        y_obs = pm.Normal("y", mu=mu, sigma=sigma, observed=y)
        
        # Correction for half distributions (alpha0 uses HalfFlat)
        pm.Potential("half_dist_correction", -1 * pt.log(2.0))

    return model