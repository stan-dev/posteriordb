import pymc as pm

def make_model(data: dict, prior_only: bool = False) -> pm.Model:
    """
    Centered Neal's Funnel for PosteriorDB
    """

    D = int(data["D"])  # Dimensionality of the funnel
    with pm.Model() as mod:
        # 1. The funnel's 'neck' or variance parameter
        y = pm.Normal("y", mu=0.0, sigma=3.0)
        
        x = pm.Normal("x", mu=0.0, sigma=pm.math.exp(y / 2.0), shape=D) 
        
        # NOTE: Synthetic distribution so no observed data is used. 
        
    return mod