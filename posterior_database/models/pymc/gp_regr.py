import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    x = data['x']
    y = data['y']
    
    x_arr = np.array(x, dtype=float)
    x_reshaped = x_arr.reshape(-1, 1)

    with pm.Model() as model:
        rho = pm.Gamma("rho", alpha=25, beta=4)
        alpha = pm.HalfNormal("alpha", sigma=2)
        sigma = pm.HalfNormal("sigma", sigma=1)
        
        sq_dist = (x_reshaped - x_reshaped.T)**2
        cov_gp = alpha**2 * pt.exp(-0.5 * sq_dist / rho**2)
        cov = cov_gp + pt.diag(pt.full(N, sigma))
        L_cov = pt.linalg.cholesky(cov)
        
        if not prior_only:
            y_obs = pm.MvNormal("y", mu=pt.zeros(N), chol=L_cov, observed=y)
        
    return model