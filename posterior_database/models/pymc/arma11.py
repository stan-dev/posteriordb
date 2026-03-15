def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np
    
    T = data['T']
    y = data['y']
    
    with pm.Model() as model:
        # Priors
        mu = pm.Normal("mu", mu=0, sigma=10)
        phi = pm.Normal("phi", mu=0, sigma=2)
        theta = pm.Normal("theta", mu=0, sigma=2)
        sigma = pm.HalfCauchy("sigma", beta=2.5)
        
        import pytensor

        # Initial conditions (t=1, which is index 0 in Python)
        nu_0 = mu + phi * mu  # assume err[0] == 0
        y_tensor = pt.as_tensor_variable(y)
        err_0 = y_tensor[0] - nu_0

        # Recursive computation using scan
        def step(y_t, y_tm1, err_tm1, mu, phi, theta_param):
            nu_t = mu + phi * y_tm1 + theta_param * err_tm1
            err_t = y_t - nu_t
            return err_t

        errs, _ = pytensor.scan(
            fn=step,
            sequences=[y_tensor[1:], y_tensor[:-1]],
            outputs_info=[err_0],
            non_sequences=[mu, phi, theta],
        )
        err = pt.concatenate([pt.atleast_1d(err_0), errs])
        
        # Likelihood: err ~ normal(0, sigma) using Potential
        log_likelihood = pt.sum(pm.logp(pm.Normal.dist(mu=0, sigma=sigma), err))
        pm.Potential("likelihood", log_likelihood)
        
    
    return model