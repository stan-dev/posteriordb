import pymc as pm

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    """
    Non-Centered Neal's Funnel for PosteriorDB
    """

    D = data.get("D", 9)
    with pm.Model() as mod:
        # 1. The funnel's 'neck' or variance parameter
        y = pm.Normal("y", mu=0.0, sigma=3.0)
        
        x_raw = pm.Normal("x_raw", mu=0.0, sigma=1.0, shape=D)
        
        x = pm.Deterministic("x", x_raw * pm.math.exp(y / 2.0))
        
        # NOTE: Synthetic distribution so no observed data is used. 
        
    return mod