"""
Run the HMC reference posterior for `stochastic_volatility-stochastic_volatility`
and export it in posteriordb format.

Model A (faithful to Hoffman & Gelman 2014): centered parameterization, tau
marginalized analytically, 3001-dimensional posterior over (s, nu).

This script:
  1. Compiles the Stan model with CmdStanPy.
  2. Runs HMC with the posteriordb-standard sampler config (10 chains,
     20000 iter, 10000 warmup, thin 10, adapt_delta 0.99, max_treedepth 20).
  3. Computes every diagnostic in posteriordb's `checks_made`:
       ndraws == 10000, nchains >= 4, R-hat < 1.01, bulk/tail ESS,
       E-FMI > 0.2, |lag-1 autocorr| < 0.05, divergences.
  4. Prints a PASS/FAIL summary so you know immediately whether the run
     qualifies as a reference posterior.
  5. If it passes (or with --force), writes the two reference files:
       reference_posteriors/draws/draws/<name>.json.zip   (#7)
       reference_posteriors/draws/info/<name>.info.json    (#8)

Expected runtime: hours. A 3001-D centered SV posterior is a hard target
(funnel geometry); divergences and R-hat failures are plausible. Read the
diagnostics before trusting the output.

Usage:
    python run_reference_posterior.py            # run, diagnose, write if pass
    python run_reference_posterior.py --force     # write files even if checks fail
    python run_reference_posterior.py --dry-run   # show config and paths, no run

Requires: cmdstanpy, numpy, arviz
Adjust REPO_ROOT / paths below to match your clone if needed.
"""

import argparse
import json
import os
import platform
import zipfile
from datetime import date

import numpy as np

# --- Configuration -----------------------------------------------------------

NAME = "stochastic_volatility-stochastic_volatility"
MODEL_NAME = "stochastic_volatility"
DATA_NAME = "stochastic_volatility"
ADDED_BY = "Colin Pochart"

# Sampler config — identical to the posteriordb standard (cf. diamonds).
CHAINS = 10
ITER_SAMPLING = 10000      # post-warmup draws per chain, BEFORE thinning
ITER_WARMUP = 10000
THIN = 10
SEED = 4711
ADAPT_DELTA = 0.99
MAX_TREEDEPTH = 20
# After thinning: 10000/10 = 1000 draws/chain * 10 chains = 10000 total draws.

# Paths — edit REPO_ROOT to point at your posterior_database directory.
REPO_ROOT = os.path.normpath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)),
                 "..", "..", "..", "..")
)
# If the auto-detected root is wrong, hardcode it, e.g.:
REPO_ROOT = r"C:\Users\colin\Documents\Projet_stage\posteriordb\posterior_database"

STAN_FILE = os.path.join(REPO_ROOT, "models", "stan", f"{MODEL_NAME}.stan")
DATA_ZIP = os.path.join(REPO_ROOT, "data", "data", f"{DATA_NAME}.json.zip")
DRAWS_ZIP = os.path.join(REPO_ROOT, "reference_posteriors", "draws", "draws",
                         f"{NAME}.json.zip")
INFO_JSON = os.path.join(REPO_ROOT, "reference_posteriors", "draws", "info",
                         f"{NAME}.info.json")


# --- Helpers -----------------------------------------------------------------

def load_stan_data():
    """Read the {T, y} dict back out of the zipped JSON data file."""
    with zipfile.ZipFile(DATA_ZIP) as zf:
        inner = zf.namelist()[0]
        return json.loads(zf.read(inner))


def lag1_autocorr(x):
    """Lag-1 autocorrelation of a 1D array."""
    x = np.asarray(x, dtype=float)
    x = x - x.mean()
    denom = np.sum(x * x)
    if denom == 0:
        return 0.0
    return float(np.sum(x[:-1] * x[1:]) / denom)


# --- Main --------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--force", action="store_true",
                    help="write reference files even if checks fail")
    ap.add_argument("--dry-run", action="store_true",
                    help="print config and exit without sampling")
    args = ap.parse_args()

    print("=" * 60)
    print(f"Reference posterior run: {NAME}")
    print(f"  stan file : {STAN_FILE}")
    print(f"  data zip  : {DATA_ZIP}")
    print(f"  draws out : {DRAWS_ZIP}")
    print(f"  info out  : {INFO_JSON}")
    print(f"  config    : {CHAINS} chains, {ITER_SAMPLING} iter "
          f"(+{ITER_WARMUP} warmup), thin {THIN}, "
          f"adapt_delta {ADAPT_DELTA}, max_treedepth {MAX_TREEDEPTH}")
    print("=" * 60)
    if args.dry_run:
        return

    from cmdstanpy import CmdStanModel
    import arviz as az

    data = load_stan_data()
    print(f"Loaded data: T = {data['T']}, len(y) = {len(data['y'])}")

    model = CmdStanModel(stan_file=STAN_FILE)
    print("Model compiled. Starting sampling (this will take a while)...")

    fit = model.sample(
        data=data,
        chains=CHAINS,
        parallel_chains=CHAINS,
        iter_sampling=ITER_SAMPLING,
        iter_warmup=ITER_WARMUP,
        thin=THIN,
        seed=SEED,
        adapt_delta=ADAPT_DELTA,
        max_treedepth=MAX_TREEDEPTH,
        show_progress=True,
    )

    # --- Diagnostics via ArviZ -----------------------------------------------
    idata = az.from_cmdstanpy(fit)
    # Model parameters only: nu (scalar) and s[1..T] (vector). Exclude lp__ etc.
    param_names = ["nu"] + [f"s[{i}]" for i in range(1, data["T"] + 1)]

    summary = az.summary(idata, var_names=["nu", "s"],
                         round_to=None, kind="all")
    rhat = summary["r_hat"].to_numpy()
    ess_bulk = summary["ess_bulk"].to_numpy()
    ess_tail = summary["ess_tail"].to_numpy()

    # Per-chain diagnostics from the sampler.
    method_vars = fit.method_variables()
    divergences = method_vars["divergent__"].sum(axis=0).astype(int).tolist()

    # E-FMI per chain.
    try:
        efmi = az.bfmi(idata).to_numpy().tolist()
    except Exception:
        efmi = az.bfmi(idata).tolist()

    # Lag-1 autocorrelation: mean over chains, per parameter.
    post = idata.posterior
    stacked = {}
    nu_draws = post["nu"].to_numpy()  # shape (chain, draw)
    stacked["nu"] = nu_draws
    s_draws = post["s"].to_numpy()    # shape (chain, draw, T)
    ndraws_total = nu_draws.shape[0] * nu_draws.shape[1]

    lag1 = []
    for c in range(nu_draws.shape[0]):
        lag1.append(lag1_autocorr(nu_draws[c]))
    mean_lag1_nu = float(np.mean(lag1))

    # --- Evaluate checks_made -------------------------------------------------
    checks = {
        "ndraws_is_10k": ndraws_total == 10000,
        "nchains_is_gte_4": CHAINS >= 4,
        "ess_within_bounds": bool(np.all(ess_bulk > 400)
                                  and np.all(ess_tail > 400)),
        "r_hat_below_1_01": bool(np.all(rhat < 1.01)),
        "efmi_above_0_2": bool(np.all(np.array(efmi) > 0.2)),
        "abs_mean_lag1_ac_below_0_05": bool(abs(mean_lag1_nu) < 0.05),
    }
    total_divergences = int(np.sum(divergences))

    print("\n" + "=" * 60)
    print("DIAGNOSTIC SUMMARY")
    print(f"  total draws         : {ndraws_total}")
    print(f"  max R-hat           : {np.max(rhat):.5f}  "
          f"(need < 1.01)")
    print(f"  min bulk ESS        : {np.min(ess_bulk):.1f}")
    print(f"  min tail ESS        : {np.min(ess_tail):.1f}")
    print(f"  min E-FMI           : {np.min(efmi):.4f}  (need > 0.2)")
    print(f"  total divergences   : {total_divergences}")
    print(f"  divergences/chain   : {divergences}")
    print("  checks_made:")
    for k, v in checks.items():
        print(f"    {'PASS' if v else 'FAIL'}  {k}")
    all_pass = all(checks.values()) and total_divergences == 0
    print(f"\n  OVERALL: {'PASS' if all_pass else 'FAIL'}")
    print("=" * 60)

    if not all_pass and not args.force:
        print("\nChecks did not all pass. No files written.")
        print("Options: investigate diagnostics, re-run with more iterations,")
        print("or submit the posterior without a reference "
              "(reference_posterior_name: null).")
        print("Use --force to write the files anyway.")
        return

    # --- Export #7: draws json.zip -------------------------------------------
    # Format: list of <nchains> dicts, each {param_name: [draws...]}.
    # Vectors flattened with 1-based indexing: s[1], s[2], ...
    chains_out = []
    nchains, ndraws_per_chain = nu_draws.shape
    for c in range(nchains):
        chain_dict = {"nu": nu_draws[c].tolist()}
        for i in range(data["T"]):
            chain_dict[f"s[{i + 1}]"] = s_draws[c, :, i].tolist()
        chains_out.append(chain_dict)

    os.makedirs(os.path.dirname(DRAWS_ZIP), exist_ok=True)
    inner_name = f"{NAME}.json"
    with zipfile.ZipFile(DRAWS_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(inner_name, json.dumps(chains_out))
    print(f"Wrote draws: {DRAWS_ZIP}")

    # --- Export #8: info.json ------------------------------------------------
    diag_names = ["nu"] + [f"s[{i}]" for i in range(1, data["T"] + 1)]
    info = {
        "name": NAME,
        "inference": {
            "method": "stan_sampling",
            "method_arguments": {
                "chains": CHAINS,
                "iter": ITER_SAMPLING + ITER_WARMUP,
                "warmup": ITER_WARMUP,
                "thin": THIN,
                "seed": SEED,
                "control": {
                    "adapt_delta": ADAPT_DELTA,
                    "max_treedepth": MAX_TREEDEPTH,
                },
            },
        },
        "diagnostics": {
            "diagnostic_information": {"names": diag_names},
            "ndraws": ndraws_total,
            "nchains": CHAINS,
            "effective_sample_size_bulk": ess_bulk.tolist(),
            "effective_sample_size_tail": ess_tail.tolist(),
            "r_hat": rhat.tolist(),
            "divergent_transitions": divergences,
            "expected_fraction_of_missing_information": list(efmi),
            "mean_lag1_ac": [mean_lag1_nu],
        },
        "checks_made": checks,
        "comments": ("Model A: faithful to Hoffman & Gelman (2014), centered "
                     "parameterization with tau marginalized analytically."),
        "added_by": ADDED_BY,
        "added_date": str(date.today()),
        "versions": {
            "cmdstanpy_run": True,
            "python_version": platform.python_version(),
            "platform": platform.platform(),
        },
    }
    os.makedirs(os.path.dirname(INFO_JSON), exist_ok=True)
    with open(INFO_JSON, "w") as f:
        json.dump(info, f, indent=2)
    print(f"Wrote info: {INFO_JSON}")
    print("\nDone. Don't forget to set reference_posterior_name in the "
          "posterior coupling file to:")
    print(f'  "{NAME}"')


if __name__ == "__main__":
    main()