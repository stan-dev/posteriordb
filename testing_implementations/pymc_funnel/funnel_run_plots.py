import pymc as pm
import arviz as az
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
from scipy.stats import gaussian_kde
from matplotlib.lines import Line2D
from multiprocessing import freeze_support

# ------------------------------------------------------------------
# Global: clean
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


COL_CENTERED    = "#1f77b4"   # blue
COL_NONCENTERED = "#2ca02c"   # green
COL_DIVERGENCE  = "#d62728"   # red
CHAIN_COLORS    = ["#4c72b0", "#dd8452", "#55a868", "#c44e52"]


# ------------------------------------------------------------------
# Helper: custom trace plot with divergences
# ------------------------------------------------------------------
def custom_trace(idata, var, title, filename, chain_colors=CHAIN_COLORS):
    """
    Plot each chain's trace with divergences shown as vertical ticks
    along the bottom of the panel.
    """
    draws = idata.posterior[var].values  # shape (chain, draw)
    n_chains, n_draws = draws.shape
    diverging = idata.sample_stats["diverging"].values  # (chain, draw)

    fig, ax = plt.subplots(figsize=(10, 3.2))

    for c in range(n_chains):
        ax.plot(
            draws[c],
            color=chain_colors[c % len(chain_colors)],
            lw=0.8, alpha=0.9,
            label=f"Chain {c+1}"
        )

    # Mark divergences as ticks under the axis
    ymin, ymax = ax.get_ylim()
    span = ymax - ymin
    tick_y = ymin - 0.06 * span
    for c in range(n_chains):
        div_idx = np.where(diverging[c])[0]
        if len(div_idx):
            ax.plot(
                div_idx, [tick_y] * len(div_idx),
                marker="|", linestyle="none",
                color=COL_DIVERGENCE, markersize=6, markeredgewidth=0.9,
                alpha=0.85
            )

    # A little headroom so ticks aren't clipped
    ax.set_ylim(ymin - 0.08 * span, ymax)

    ax.set_xlabel("Draw")
    ax.set_ylabel(var)
    ax.set_title(title)
    ax.legend(loc="upper right", ncols=n_chains, fontsize=8)

    n_div = int(diverging.sum())
    ax.text(
        0.01, 0.97, f"Divergences: {n_div}",
        transform=ax.transAxes,
        va="top", ha="left",
        fontsize=9,
        color=COL_DIVERGENCE if n_div else "#444",
        bbox=dict(boxstyle="round,pad=0.3",
                  fc="white", ec="0.8", lw=0.6, alpha=0.9)
    )

    fig.tight_layout()
    fig.savefig(filename, bbox_inches="tight")
    plt.show()


# ------------------------------------------------------------------
# Helper: funnel scatter with density coloring
# ------------------------------------------------------------------
def funnel_scatter(
    idata, title, filename,
    color=COL_CENTERED,
    xlim=(-16, 11), ylim=(-220, 420),
    show_divergences=True,
):
    """
    Scatter of v vs x[0], colored by local point density,
    with divergences overlaid as red X markers.
    """
    v = idata.posterior["v"].values.flatten()
    x = idata.posterior["x"].sel(x_dim_0=0).values.flatten()
    div = idata.sample_stats["diverging"].values.flatten().astype(bool)

    fig, ax = plt.subplots(figsize=(7, 5))

    # Density-colored scatter for non-divergent points
    ok = ~div if show_divergences else np.ones_like(div)
    sc = ax.scatter(
        v[ok], x[ok],
        c=np.abs(x[ok]), cmap="viridis",
        s=9, alpha=0.55, linewidths=0,
    )
    cbar = fig.colorbar(sc, ax=ax, pad=0.02)
    cbar.set_label("|x[0]|")

    if show_divergences and div.sum() > 0:
        ax.scatter(
            v[div], x[div],
            marker="x", s=55, linewidths=1.6,
            color=COL_DIVERGENCE, zorder=5,
            label=f"Divergences (n={int(div.sum())})"
        )
        ax.legend(loc="upper left", fontsize=9)

    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_xlabel("v")
    ax.set_ylabel("x[0]")
    ax.set_title(title)

    fig.tight_layout()
    fig.savefig(filename, bbox_inches="tight")
    plt.show()


# ------------------------------------------------------------------
# Helper: sampling-space scatter (v vs x_raw)
# ------------------------------------------------------------------
def sampling_space_scatter(idata, title, filename):
    v = idata.posterior["v"].values.flatten()
    xr = idata.posterior["x_raw"].sel(x_raw_dim_0=0).values.flatten()

    fig, ax = plt.subplots(figsize=(7, 5))
    sc = ax.scatter(
        v, xr,
        c=np.abs(xr), cmap="viridis",
        s=9, alpha=0.55, linewidths=0,
    )
    cbar = fig.colorbar(sc, ax=ax, pad=0.02)
    cbar.set_label("|x_raw[0]|")

    ax.set_xlabel("v")
    ax.set_ylabel("x_raw[0]")
    ax.set_title(title)

    fig.tight_layout()
    fig.savefig(filename, bbox_inches="tight")
    plt.show()


# ------------------------------------------------------------------
# Helper: overlay posterior densities of v
# ------------------------------------------------------------------
from scipy.stats import gaussian_kde

def overlay_v_density(idata_c, idata_nc, filename):
    """
    Overlay KDEs of v from centered and non-centered models.
    Manual implementation -> no dependency on az.plot_density.
    """
    v_c  = idata_c.posterior["v"].values.flatten()
    v_nc = idata_nc.posterior["v"].values.flatten()

    # Use the well-mixed model to define the grid range
    lo, hi = np.percentile(v_nc, [0.5, 99.5])
    grid = np.linspace(lo - 1.0, hi + 1.0, 500)

    kde_c  = gaussian_kde(v_c,  bw_method=0.30)
    kde_nc = gaussian_kde(v_nc, bw_method=0.30)

    fig, ax = plt.subplots(figsize=(7, 4))

    ax.fill_between(grid, kde_c(grid),  alpha=0.22, color=COL_CENTERED)
    ax.plot(grid, kde_c(grid),  color=COL_CENTERED, lw=1.8,
            label=f"Centered (ESS≈{int(az.ess(idata_c, var_names=['v'])['v'].values)})")

    ax.fill_between(grid, kde_nc(grid), alpha=0.22, color=COL_NONCENTERED)
    ax.plot(grid, kde_nc(grid), color=COL_NONCENTERED, lw=1.8,
            label=f"Non-Centered (ESS≈{int(az.ess(idata_nc, var_names=['v'])['v'].values)})")

    ax.set_xlabel("v")
    ax.set_ylabel("Density")
    ax.set_title("Posterior density of v — Centered vs Non-Centered")
    ax.legend(loc="upper right", fontsize=9)

    fig.tight_layout()
    fig.savefig(filename, bbox_inches="tight")
    plt.show()

# ==================================================================
# MAIN
# ==================================================================
if __name__ == "__main__":
    print("=== Generating styled diagnostic plots ===\n")

    # ---------- Centered ----------
    print("Running Centered model...")
    with pm.Model() as centered_model:
        v = pm.Normal("v", mu=0, sigma=3)
        sigma_x = pm.math.exp(v / 2)
        x = pm.Normal("x", mu=0, sigma=sigma_x, shape=9)

        idata_centered = pm.sample(
            draws=1000, tune=1000, chains=4, cores=1,
            random_seed=42, progressbar=True,
        )

    # ---------- Non-centered ----------
    print("\nRunning Non-Centered model...")
    with pm.Model() as noncentered_model:
        v = pm.Normal("v", mu=0, sigma=3)
        x_raw = pm.Normal("x_raw", mu=0, sigma=1, shape=9)
        x = pm.Deterministic("x", x_raw * pm.math.exp(v / 2))

        idata_noncentered = pm.sample(
            draws=1000, tune=1000, chains=4, cores=1,
            random_seed=42, progressbar=True,
        )

    # ---------- Trace plots ----------
    print("\nCreating styled trace plots...")
    custom_trace(
        idata_centered, "v",
        "Centered — Trace plot of v",
        "trace_centered.png"
    )
    custom_trace(
        idata_noncentered, "v",
        "Non-Centered — Trace plot of v",
        "trace_noncentered.png"
    )

    # ---------- Funnel scatters (shared axes) ----------
    print("Creating styled funnel scatter plots...")
    funnel_scatter(
        idata_centered,
        "Centered — Funnel scatter (v vs x[0])",
        "funnel_centered.png",
        color=COL_CENTERED,
    )
    funnel_scatter(
        idata_noncentered,
        "Non-Centered — Funnel scatter (v vs x[0])",
        "funnel_noncentered.png",
        color=COL_NONCENTERED,
    )

    # ---------- Sampling space ----------
    print("Creating sampling-space plot...")
    sampling_space_scatter(
        idata_noncentered,
        "Non-Centered — Sampling space (v vs x_raw[0])",
        "sampling_space_noncentered.png"
    )

    # ---------- Posterior density of v ----------
    print("Creating posterior density comparison...")
    overlay_v_density(idata_centered, idata_noncentered, "posterior_v_comparison.png")

    print("\nAll plots saved:")
    for f in [
        "trace_centered.png",
        "trace_noncentered.png",
        "funnel_centered.png",
        "funnel_noncentered.png",
        "sampling_space_noncentered.png",
        "posterior_v_comparison.png",
    ]:
        print(f"  - {f}")