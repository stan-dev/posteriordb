import pymc as pm
import arviz as az
from multiprocessing import freeze_support

freeze_support()

if __name__ == '__main__':
    print("--- Tiny sampling test: Haario banana ---")

    b = 0.1

    with pm.Model() as banana_model:
        x = pm.Normal("x", mu=0, sigma=10)
        y = pm.Normal("y", mu=b * (x**2 - 100), sigma=1)

        print("Starting tiny sampling (draws=50, tune=50, chains=1, cores=1)...")
        idata = pm.sample(
            draws=1000,
            tune=1000,
            chains=1,
            cores=1,
            random_seed=42,
            progressbar=True
        )

    print("\nTiny sampling finished!")
    divergences = idata.sample_stats["diverging"].sum().item()
    print(f"Number of Divergent Transitions: {divergences}")