import pymc as pm
import arviz as az
from multiprocessing import freeze_support

freeze_support()

if __name__ == '__main__':
    print("--- Step 2: Non-Centered Neal's Funnel ---")

    with pm.Model() as noncentered_model:
        # Non-centered parameterization
        v = pm.Normal("v", mu=0, sigma=3)
        
        # x_raw ~ Normal(0, 1), then scale it
        x_raw = pm.Normal("x_raw", mu=0, sigma=1, shape=9)
        x = pm.Deterministic("x", x_raw * pm.math.exp(v / 2))

        print("Starting sampling: draws=1000, tune=1000, chains=4, cores=1")
        
        idata_nc = pm.sample(
            draws=1000,
            tune=1000,
            chains=4,
            cores=1,
            random_seed=42,
            progressbar=True
        )

    print("\nSampling finished!")
    
    divergences = idata_nc.sample_stats["diverging"].sum().item()
    print(f"Number of Divergent Transitions: {divergences}")

    print("\nSummary for v:")
    print(az.summary(idata_nc, var_names=["v"]))