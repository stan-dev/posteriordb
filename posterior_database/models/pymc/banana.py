import numpy as np
import pymc as pm

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    
    D = int(data["D"])
    b = float(data["b"])
    v = 100.0

    with pm.Model() as model:
        # First coordinate: N(0, sqrt(v))
        x = pm.Normal("x", mu=0.0, sigma=np.sqrt(v))

        # Twisted second coordinate: N(-b*(x^2 - v), 1)
        mu_y = -b * (x**2 - v)
        y = pm.Normal("y", mu=mu_y, sigma=1.0)

        # Remaining dimensions for D > 2
        if D > 2:
            pm.Normal("y_rest", mu=0.0, sigma=1.0, shape=D - 2)

    return model
