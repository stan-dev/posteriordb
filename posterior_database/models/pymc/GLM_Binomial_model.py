import numpy as np
import pymc as pm

def model(data):
    
    with pm.Model(coords={"year": range(40)}) as pymc_model:    
        year = pm.Data("year_data", np.array(data["year"]), dims="year")
        N = pm.Data("N_data", np.array(data["N"]), dims="year")
        C = pm.Data("C_data", np.array(data["C"]), dims="year")
        
        alpha = pm.Normal("alpha", mu=0, sigma=100)
        beta1 = pm.Normal("beta1", mu=0, sigma=100)
        beta2 = pm.Normal("beta2", mu=0, sigma=100)

        year_squared = year ** 2
        logit_p = alpha + beta1 * year + beta2 * year_squared        
        pm.Binomial("C", n=N, logit_p=logit_p, observed=C, dims="year")

        p = pm.Deterministic("p", pm.math.invlogit(logit_p), dims="year")
    
    return pymc_model
