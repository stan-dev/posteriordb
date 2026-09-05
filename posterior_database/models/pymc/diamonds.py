import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    Y = data['Y']
    K = data['K'] 
    X = np.asarray(data['X'])
    
    Kc = K - 1
    means_X = X[:, 1:].mean(axis=0)
    Xc = X[:, 1:] - means_X
    
    with pm.Model() as model:
        b = pm.Normal("b", mu=0, sigma=1, shape=Kc)
        Intercept = pm.StudentT("Intercept", nu=3, mu=8, sigma=10)
        sigma = pm.HalfStudentT("sigma", nu=3, sigma=10)
        
        if not prior_only:
            mu = Intercept + pm.math.dot(Xc, b)
            Y_obs = pm.Normal("Y", mu=mu, sigma=sigma, observed=Y)

    return model