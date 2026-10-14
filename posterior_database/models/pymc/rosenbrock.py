import pymc as pm
import pytensor.tensor as pt

def make_model(data: dict) -> pm.Model:
    # Explicit key extraction (no silent KeyError fallbacks)
    n1 = int(data["n1"])
    n2 = int(data["n2"])
    mu = float(data["mu"])
    a = float(data["a"])
    b = float(data["b"])
    
    # Calculate total dimension n = (n1 - 1) * n2 + 1
    n = (n1 - 1) * n2 + 1

    def hybrid_rosenbrock_logp(x):
        # x is a single 1D vector of shape (n,)
        logp_root = -a * pt.sqr(x - mu)
        logp_blocks = 0.0
        idx = 1
        for j in range(n2):
            prev = x
            for i in range(1, n1):
                logp_blocks += -b * pt.sqr(x[idx] - pt.sqr(prev))
                prev = x[idx]
                idx += 1
        return logp_root + logp_blocks

    with pm.Model() as model:
        # Single vector parameter 'x' matching Stan's vector[n] x
        pm.CustomDist("x", logp=hybrid_rosenbrock_logp, shape=(n,))

    return model
