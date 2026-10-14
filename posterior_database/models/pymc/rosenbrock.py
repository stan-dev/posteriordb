import pymc as pm
import pytensor.tensor as pt

def make_model(data: dict) -> pm.Model:
    n1 = int(data["n1"])
    n2 = int(data["n2"])
    mu = float(data["mu"])
    a = float(data["a"])
    b = float(data["b"])

    def hybrid_rosenbrock_logp(x1, x_rest):
        logp_root = -a * pt.sqr(x1 - mu)
        logp_blocks = 0.0
        
        for j in range(n2):
            prev = x1
            for i in range(n1 - 1):
                logp_blocks += -b * pt.sqr(x_rest[j, i] - pt.sqr(prev))
                prev = x_rest[j, i]
                
        return logp_root + logp_blocks

    with pm.Model() as model:
        # These names ("x1" and "x_rest") map exactly to the Stan parameters
        x1 = pm.Flat("x1")
        x_rest = pm.Flat("x_rest", shape=(n2, n1 - 1))
        
        # We USE the function here to define the target density
        pm.Potential("rosenbrock_target", hybrid_rosenbrock_logp(x1, x_rest))

    return model