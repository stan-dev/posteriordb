def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data
    growthmodel_id = data['growthmodel_id']
    n_data = data['n_data']
    n_time = data['n_time']
    n_cohort = data['n_cohort']
    cohort_id = np.array(data['cohort_id']) - 1  # Convert to 0-based indexing
    t_idx = np.array(data['t_idx']) - 1  # Convert to 0-based indexing
    cohort_maxtime = np.array(data['cohort_maxtime'])
    t_value = np.array(data['t_value'])
    premium = np.array(data['premium'])
    loss = np.array(data['loss'])

    def growth_factor_weibull(t, omega, theta):
        return 1 - pt.exp(-((t / theta) ** omega))
    
    def growth_factor_loglogistic(t, omega, theta):
        pow_t_omega = t ** omega
        return pow_t_omega / (pow_t_omega + theta ** omega)

    with pm.Model() as model:
        # Parameters
        omega = pm.LogNormal("omega", mu=0, sigma=0.5)
        theta = pm.LogNormal("theta", mu=0, sigma=0.5)
        
        mu_LR = pm.Normal("mu_LR", mu=0, sigma=0.5)
        sd_LR = pm.LogNormal("sd_LR", mu=0, sigma=0.5)
        
        LR = pm.LogNormal("LR", mu=mu_LR, sigma=sd_LR, shape=n_cohort)
        
        loss_sd = pm.LogNormal("loss_sd", mu=0, sigma=0.7)
        
        # Transformed parameters
        # Compute growth factors for all time points
        if growthmodel_id == 1:
            gf = growth_factor_weibull(t_value, omega, theta)
        else:
            gf = growth_factor_loglogistic(t_value, omega, theta)
        
        gf = pm.Deterministic("gf", gf)
        
        # Compute loss mean for each observation
        lm = LR[cohort_id] * premium[cohort_id] * gf[t_idx]
        lm = pm.Deterministic("lm", lm)
        
        # Likelihood
        # loss ~ normal(lm, (loss_sd * premium)[cohort_id])
        sigma_obs = loss_sd * premium[cohort_id]
        loss_obs = pm.Normal("loss", mu=lm, sigma=sigma_obs, observed=loss)

    return model