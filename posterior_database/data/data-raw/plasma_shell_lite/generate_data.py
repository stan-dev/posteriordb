"""
Simulate data for the plasma "shell" model (Langmore et al., arXiv:2103.07515, sec. 2.3).

Writes
  plasma_shell_sim.json    -> exactly the Stan `data` block (share this with the PyMC colleague)
  plasma_shell_truth.json  -> the simulated truth (NOT model data; for recovery checks / logp comparison)
  plasma_sim_check.png     -> sanity plot (only if matplotlib is installed)

Everything marked [paper] comes from the paper; the rest are documented choices.
"""
import json
import numpy as np

import sys

SEED = 1

# Two presets share one code path:
#   full : the larger dataset (default; reproduces plasma_shell_sim.json exactly)
#   lite : smaller and noisier, so the posterior is cheaper and wider
PRESET = sys.argv[1] if len(sys.argv) > 1 else "full"
if PRESET not in ("full", "lite"):
    sys.exit("usage: python3 generate_data.py [full|lite]")
FULL = PRESET == "full"

# ---- geometry ---------------------------------------------------------------
G = 20 if FULL else 10          # G x G pixel grid on [-1, 1]^2              [choice]
M_PER_DIR = 20 if FULL else 10  # chords per direction (Fig. 2 uses 20)      [paper count / choice]
M = 2 * M_PER_DIR               # vertical + horizontal chords (breaks the c_y -> -c_y symmetry) [choice]
P = G * G
K = 60 if FULL else 30          # frequencies (paper: ~200)                  [choice]
R = 12 if FULL else 8           # radial nodes                               [choice]
R_MAX = 3.0 if FULL else 2.0    # radial grid end; farthest pixel from a centre near 0 is ~1.8 [choice]

# ---- constants --------------------------------------------------------------
NU_LO, NU_HI = 229.5, 229.9   # measurement bounds, Fig. 3            [paper, read off figure]
NU_0 = 229.7                  # centre of window / Carbon III line    [paper, inferred]
TAU = 0.2                     # prior correlation length              [paper value, one of two]
DELTA = 0.001                 # shrinkage                             [paper]
SIGMA_C = 0.1                 # sd of centre prior                    [choice]
SIGMA = 5.0 if FULL else 15.0 # additive noise (paper range 1.25-15)  [paper range]
SIGMA_P = 0.05                # proportional noise                    [choice]
C_A = 7e-4 if FULL else 2e-4  # amplitude scale; full: peaks ~1e3 as in Fig. 3, lite: ~3e2 [chosen]
C_T = 2e-8                    # temperature scale                     [chosen: w ~ 1-4 freq spacings]
C_V = 1e-4                    # velocity scale                        [chosen: shift ~ 1 line width / unit f]

OUT = "plasma_shell_sim" if FULL else "plasma_shell_lite_sim"
OUT_TRUTH = "plasma_shell_truth" if FULL else "plasma_shell_lite_truth"
OUT_PNG = "plasma_sim_check.png" if FULL else "plasma_shell_lite_check.png"

# ---- build -------------------------------------------------------------------
rng = np.random.default_rng(SEED)

xs = -1 + (np.arange(G) + 0.5) * 2 / G
Xg, Yg = np.meshgrid(xs, xs)                       # Xg[i, j] = xs[j], Yg[i, j] = xs[i]
xy = np.column_stack([Xg.ravel(), Yg.ravel()])     # pixel p = i*G + j  (row-major)
col = np.arange(P) % G                             # x index of each pixel
row = np.arange(P) // G                            # y index of each pixel

I_mat = np.zeros((M, P))
for m in range(M_PER_DIR):
    I_mat[m, col == m] = 2 / G                     # vertical chords   (integrate along y)
    I_mat[M_PER_DIR + m, row == m] = 2 / G         # horizontal chords (integrate along x)

nu = np.linspace(NU_LO, NU_HI, K)
r_grid = np.linspace(0.0, R_MAX, R)

# prior covariance of radial profile (delta*I, not a constant added to all entries)
C = np.exp(-(r_grid[:, None] - r_grid[None, :]) ** 2 / (2 * TAU**2)) + DELTA * np.eye(R)
L = np.linalg.cholesky(C)

softplus = lambda u: np.log1p(np.exp(u))


def mu_fn(fA, fT, fV, ctr):
    """Noise-free chord spectra, M x K. Mirrors mu_fn in plasma_shell.stan."""
    r = np.sqrt(((xy - ctr) ** 2).sum(1) + 1e-12)
    A = C_A * softplus(np.interp(r, r_grid, fA))
    T = C_T * softplus(np.interp(r, r_grid, fT))
    V = C_V * np.interp(r, r_grid, fV)
    w = np.sqrt(T) / NU_0
    nu_tilde_inv = (1 - V) / NU_0
    emis = (A / (np.sqrt(2 * np.pi) * w))[:, None] * np.exp(
        -((1 / nu)[None, :] - nu_tilde_inv[:, None]) ** 2 / (2 * w[:, None] ** 2)
    )
    return I_mat @ emis


# ---- simulate truth from the prior -------------------------------------------
Z_A, Z_T, Z_V = (rng.standard_normal(R) for _ in range(3))
c_raw = rng.standard_normal(2)
ctr = SIGMA_C * c_raw
mu = mu_fn(L @ Z_A, L @ Z_T, L @ Z_V, ctr)
sd = np.sqrt(SIGMA**2 + (SIGMA_P * mu) ** 2)
Y = mu + rng.standard_normal(mu.shape) * sd

data = dict(
    P=P, M=M, K=K, R=R,
    nu=nu.tolist(), nu_0=NU_0,
    I_mat=I_mat.tolist(), Y=Y.tolist(),
    xy=xy.tolist(), r_grid=r_grid.tolist(),
    tau=TAU, delta=DELTA, sigma_c=SIGMA_C,
    c_A=C_A, c_T=C_T, c_V=C_V,
    sigma=SIGMA, sigma_p=SIGMA_P,
)
truth = dict(seed=SEED, Z_A=Z_A.tolist(), Z_T=Z_T.tolist(), Z_V=Z_V.tolist(),
             c_raw=c_raw.tolist(), ctr=ctr.tolist())

with open(OUT + ".json", "w") as f:
    json.dump(data, f)
with open(OUT_TRUTH + ".json", "w") as f:
    json.dump(truth, f)

# ---- sanity report -----------------------------------------------------------
dinv = abs(np.diff(1 / nu).mean())
print(f"preset={PRESET} M={M} K={K} P={P} R={R}")
print(f"true centre = {np.round(ctr, 3)}")
print(f"noise-free signal: min {mu.min():.3g}, max {mu.max():.3g}")
print(f"peak position (freq index) per chord: min {mu.argmax(1).min()}, max {mu.argmax(1).max()} of {K-1}")
i_pk = np.unravel_index(mu.argmax(), mu.shape)
print(f"signal-to-noise at the highest peak: {mu[i_pk] / sd[i_pk]:.1f}")
T_pix = C_T * softplus(np.interp(np.sqrt(((xy - ctr) ** 2).sum(1)), r_grid, L @ Z_T))
w_pix = np.sqrt(T_pix) / NU_0
print(f"line width w in frequency-grid spacings: {w_pix.min() / abs(np.diff(1 / nu).mean()):.2f}"
      f" - {w_pix.max() / abs(np.diff(1 / nu).mean()):.2f}  (want >~1)")

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, ax = plt.subplots(1, 2, figsize=(10, 3.5))
    half = M_PER_DIR
    for m in range(0, half, max(1, half // 5)):
        ax[0].plot(nu, Y[m], lw=0.8)
    ax[0].set_title("vertical chords (data)")
    for m in range(half, M, max(1, half // 5)):
        ax[1].plot(nu, Y[m], lw=0.8)
    ax[1].set_title("horizontal chords (data)")
    for a in ax:
        a.set_xlabel("wavelength")
    plt.tight_layout()
    plt.savefig(OUT_PNG, dpi=120)
    print(f"wrote {OUT_PNG}")
except ImportError:
    pass
