import pymc as pm
import arviz as az
from multiprocessing import freeze_support

freeze_support()

if __name__ == '__main__':
    print("--- Step 1: Centered model with 4 chains (sequential) ---")

    with pm.Model() as centered_model:
        # v ~ Normal(0, 3)
        v = pm.Normal("v", mu=0, sigma=3)

        # x ~ Normal(0, exp(v/2)) across 9 dimensions
        sigma_x = pm.math.exp(v / 2)
        x = pm.Normal("x", mu=0, sigma=sigma_x, shape=9)

        print("Starting sampling: draws=1000, tune=1000, chains=4, cores=1")
        print("This will take longer because the 4 chains run one after another...")
        
        idata = pm.sample(
            draws=1000, #2000 for improvement
            tune=1000, #2000 for improvement
            chains=4,
            cores=1, # still sequential 
            #target_accept=0.95, # added to check for improvements later for 2000 versions, not needed otherwise
            random_seed=42,
            progressbar=True
        )

    print("\nSampling finished!")
    
    # Divergences
    divergences = idata.sample_stats["diverging"].sum().item()
    print(f"Number of Divergent Transitions: {divergences}")

    # Summary (now R-hat should appear)
    print("\nSummary for v:")
    print(az.summary(idata, var_names=["v"]))