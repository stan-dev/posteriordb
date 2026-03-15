def make_model(data: dict) -> pm.Model:
    """PyMC model transpiled from Stan."""
    import pymc as pm
    import pytensor.tensor as pt
    import numpy as np

    # Extract data and ensure numpy arrays
    N = data['N']
    partyid7 = np.asarray(data['partyid7'], dtype=float)
    real_ideo = np.asarray(data['real_ideo'], dtype=float)
    race_adj = np.asarray(data['race_adj'], dtype=float)
    educ1 = np.asarray(data['educ1'], dtype=float)
    gender = np.asarray(data['gender'], dtype=float)
    income = np.asarray(data['income'], dtype=float)
    age_discrete = np.asarray(data['age_discrete'])
    
    # Transformed data: create age indicator variables
    age30_44 = np.array(age_discrete == 2, dtype=float)
    age45_64 = np.array(age_discrete == 3, dtype=float)
    age65up = np.array(age_discrete == 4, dtype=float)

    with pm.Model() as model:
        # Parameters - no priors specified in Stan, so use flat priors
        beta = pm.Flat("beta", shape=9)
        sigma = pm.HalfFlat("sigma")
        
        # Model: vectorized linear regression
        mu = (beta[0] + 
              beta[1] * real_ideo + 
              beta[2] * race_adj +
              beta[3] * age30_44 + 
              beta[4] * age45_64 +
              beta[5] * age65up + 
              beta[6] * educ1 + 
              beta[7] * gender +
              beta[8] * income)
        
        # Likelihood
        partyid7_obs = pm.Normal("partyid7", mu=mu, sigma=sigma, observed=partyid7)
        
        # Stan uses proportional densities, so we need to remove the normalization constants
        # For N normal distributions, the normalization constant is N * log(sqrt(2*pi))
        # For HalfFlat, we need to remove log(2)
        pm.Potential("stan_normalization", 
                     N * pt.log(pt.sqrt(2 * np.pi)) - pt.log(2.0))

    return model