import pymc as pm
import pytensor.tensor as pt
import numpy as np

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    N = data['N']
    x = np.array(data['x'], dtype=float)
    k = np.array(data['k'])

    with pm.Model() as model:
        
        rho = pm.Gamma("rho", alpha=25, beta=4)
        alpha = pm.HalfNormal("alpha", sigma=2)
        f_tilde = pm.Normal("f_tilde", mu=0, sigma=1, shape=N)
        
        x_tensor = pt.as_tensor_variable(x)
        x_diff = x_tensor[:, None] - x_tensor[None, :]
        sqdist = x_diff ** 2
        cov = alpha**2 * pt.exp(-0.5 * sqdist / rho**2)
        cov = cov + pt.eye(N) * 1e-10
        L_cov = pt.linalg.cholesky(cov)
        
        f = pm.Deterministic("f", L_cov @ f_tilde)
        
        if not prior_only:
            k_obs = pm.Poisson("k", mu=pt.exp(f), observed=k)
    
    return model