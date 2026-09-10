import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:

    N = data['N']
    Y = data['Y']
    Ks = data['Ks']
    Xs = data['Xs']
    knots_1 = data['knots_1']
    Zs_1_1 = data['Zs_1_1']
    Ks_sigma = data['Ks_sigma']
    Xs_sigma = data['Xs_sigma']
    knots_sigma_1 = data['knots_sigma_1']
    Zs_sigma_1_1 = data['Zs_sigma_1_1']

    with pm.Model() as model:
        Intercept = pm.StudentT("Intercept", nu=3, mu=-13, sigma=36)
        bs = pm.Flat("bs", shape=Ks)
        
        zs_1_1 = pm.Normal("zs_1_1", mu=0, sigma=1, shape=knots_1)
        sds_1_1 = pm.Truncated("sds_1_1", pm.StudentT.dist(nu=3, mu=0, sigma=36), lower=0)
        
        Intercept_sigma = pm.StudentT("Intercept_sigma", nu=3, mu=0, sigma=10)
        bs_sigma = pm.Flat("bs_sigma", shape=Ks_sigma)
        
        zs_sigma_1_1 = pm.Normal("zs_sigma_1_1", mu=0, sigma=1, shape=knots_sigma_1)
        sds_sigma_1_1 = pm.Truncated("sds_sigma_1_1", pm.StudentT.dist(nu=3, mu=0, sigma=36), lower=0)
        
        s_1_1 = pm.Deterministic("s_1_1", sds_1_1 * zs_1_1)
        s_sigma_1_1 = pm.Deterministic("s_sigma_1_1", sds_sigma_1_1 * zs_sigma_1_1)
        
        mu_linear = Intercept + Xs @ bs + Zs_1_1 @ s_1_1
        sigma_linear = Intercept_sigma + Xs_sigma @ bs_sigma + Zs_sigma_1_1 @ s_sigma_1_1
        
        sigma = pm.Deterministic("sigma", pt.exp(sigma_linear))
        
        if not prior_only:
            Y_obs = pm.Normal("Y", mu=mu_linear, sigma=sigma, observed=Y)
    
    return model