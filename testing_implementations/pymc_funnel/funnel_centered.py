import pymc as pm
import arviz as az
from multiprocessing import freeze_support

freeze_support()

if __name__ == '__main__':
    print("--- Sampling test ---")
    
    with pm.Model() as centered_model:
        v = pm.Normal("v", mu=0, sigma=3)
        sigma_x = pm.math.exp(v / 2)
        x = pm.Normal("x", mu=0, sigma=sigma_x, shape=9)
        
        print("Starting sampling (draws=500, tune=500)...")
        idata = pm.sample(
            draws=1000, #50, 500 tried
            tune=1000, #50, 500 tried
            chains=1,
            cores=1,
            random_seed=42,
            progressbar=True
        )
    
    print("\nSampling finished!")
    divergences = idata.sample_stats["diverging"].sum().item()
    print(f"Number of Divergent Transitions: {divergences}")
    
    # Optional: show a quick summary of v
    print("\nSummary for v:")
    print(az.summary(idata, var_names=["v"]))