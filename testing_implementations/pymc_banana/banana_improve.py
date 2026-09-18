import pymc as pm
import arviz as az
from multiprocessing import freeze_support

freeze_support()

if __name__ == '__main__':
    print("--- Improved medium sampling: Haario banana ---")

    b = 0.1

    with pm.Model() as banana_model:
        x = pm.Normal("x", mu=0, sigma=10)
        y = pm.Normal("y", mu=b * (x**2 - 100), sigma=1)

        idata = pm.sample(
            draws=1000,
            tune=2000,               # more tuning
            chains=4,
            cores=1,
            target_accept=0.95,      # key improvement
            random_seed=42,
            progressbar=True
        )

    print("\nSampling finished!")
    divergences = idata.sample_stats["diverging"].sum().item()
    print(f"Number of Divergent Transitions: {divergences}")
    print("\nSummary:")
    print(az.summary(idata, var_names=["x", "y"]))