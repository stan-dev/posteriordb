import pymc as pm
import arviz as az
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
from scipy.stats import gaussian_kde
from multiprocessing import freeze_support

# ------------------------------------------------------------------
# Global style
# ------------------------------------------------------------------
mpl.rcParams.update({
    "figure.dpi": 120,
    "savefig.dpi": 200,
    "font.size": 11,
    "axes.titlesize": 13,
    "axes.titleweight": "bold",
    "axes.labelsize": 11,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.grid": True,
    "grid.alpha": 0.25,
    "grid.linewidth": 0.6,
    "legend.frameon": False,
    "xtick.direction": "out",
    "ytick.direction": "out",
})

COL_MAIN       = "#1f77b4"   # blue
COL_DIVERGENCE = "#d62728"   # red
CHAIN_COLORS   = ["#4c72b0", "#dd8452", "#55a868", "#c44e52"]


# ------------------------------------------------------------------
# Custom trace plot with divergence ticks
# ------------------------------------------------------------------
def custom_trace(idata, var, title, filename):
    draws = idata.posterior[var].values          # (chain, draw)
    n_chains, n_draws = draws.shape
    diverging = idata.sample_stats["diverging"].values

    fig, ax = plt.subplots(figsize=(10, 3.2))

    for c in range(n_chains):
        ax.plot(draws[c], color=CHAIN_COLORS[c % len(CHAIN_COLORS)],
                lw=0.8, alpha=0.9, label=f"Chain {c+1}")

    # Divergence markers under the axis
    ymin, ymax = ax.get_ylim()
    span = ymax - ymin
    tick_y = ymin - 0.06 * span
    for c in range(n_chains):
        div_idx = np.where(diverging[c])[0]
        if len(div_idx):
            ax.plot(div_idx, [tick_y] * len(div_idx),
                    marker="|", linestyle="none",
                    color=COL_DIVERGENCE, markersize=6, markeredgewidth=0.9,
                    alpha=0.85)

    ax.set_ylim(ymin - 0.08 * span, ymax)
    ax.set_xlabel("Draw")
    ax.set_ylabel(var)
    ax.set_title(title)
    ax.legend(loc="upper right", ncols=n_chains, fontsize=8)

    n_div = int(diverging.sum())
    ax.text(0.01, 0.97, f"Divergences: {n_div}",
            transform=ax.transAxes, va="top", ha="left", fontsize=9,
            color=COL_DIVERGENCE if n_div else "#444",
            bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="0.8", lw=0.6, alpha=0.9))

    fig.tight_layout()
    fig.savefig(filename, bbox_inches="tight")
    plt.show()


# ------------------------------------------------------------------
# Banana scatter (x vs y) with density coloring
# ------------------------------------------------------------------
def banana_scatter(idata, title, filename):
    x = idata.posterior["x"].values.flatten()
    y = idata.posterior["y"].values.flatten()
    div = idata.sample_stats["diverging"].values.flatten().astype(bool)

    fig, ax = plt.subplots(figsize=(7.5, 5.5))

    # Density-colored non-divergent points
    ok = ~div
    sc = ax.scatter(x[ok], y[ok],
                    c=np.abs(y[ok]), cmap="viridis",
                    s=10, alpha=0.55, linewidths=0)
    cbar = fig.colorbar(sc, ax=ax, pad=0.02)
    cbar.set_label("|y|")

    # Divergences (if any)
    if div.sum() > 0:
        ax.scatter(x[div], y[div],
                   marker="x", s=60, linewidths=1.6,
                   color=COL_DIVERGENCE, zorder=5,
                   label=f"Divergences (n={int(div.sum())})")
        ax.legend(loc="upper left", fontsize=9)

    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_title(title)

    fig.tight_layout()
    fig.savefig(filename, bbox_inches="tight")
    plt.show()


# ==================================================================
# MAIN
# ==================================================================
freeze_support()

if __name__ == "__main__":
    print("=== Generating styled diagnostic plots for Haario banana ===\n")

    b = 0.1

    print("Running improved banana model...")
    with pm.Model() as banana_model:
        x = pm.Normal("x", mu=0, sigma=10)
        y = pm.Normal("y", mu=b * (x**2 - 100), sigma=1)

        idata = pm.sample(
            draws=1000,
            tune=2000,
            chains=4,
            cores=1,
            target_accept=0.95,
            random_seed=42,
            progressbar=True
        )

    print("\nCreating styled plots...")

    # Trace plots
    custom_trace(idata, "x", "Haario Banana — Trace of x", "banana_trace_x.png")
    custom_trace(idata, "y", "Haario Banana — Trace of y", "banana_trace_y.png")

    # Banana scatter
    banana_scatter(idata, "Haario Banana — Scatter (x vs y)", "banana_scatter.png")

    print("\nPlots saved:")
    print("  - banana_trace_x.png")
    print("  - banana_trace_y.png")
    print("  - banana_scatter.png")