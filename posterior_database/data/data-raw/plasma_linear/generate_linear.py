"""
Simulate data for the linear Gaussian toy version of the plasma model
(Langmore et al., arXiv:2103.07515, eqs. 1-2 and Fig. 4).

The paper obtains this toy from the spectroscopy model by keeping only the
amplitude, dropping the softplus, and setting sigma_p = 0, c_A = 1.

    x ~ N(0, C_pr),   C_pr[i, j] = exp(-(s_i - s_j)^2 / (2 tau^2)) + delta * 1{i = j}
    y ~ N(A x, sigma^2 I)

The posterior is exactly Gaussian, so this script also writes the analytic
posterior. That gives a tool-independent reference for both Stan and PyMC.

Writes
  plasma_linear.json            -> data (matches the Stan `data` block)
  plasma_linear_truth.json      -> simulated truth (not model input)
  plasma_linear_reference.json  -> analytic posterior mean/sd of x and Z
"""
import json
import numpy as np

SEED = 1

N = 40          # unknowns on a 1-D grid                       [paper, Fig. 1/4]
M = 20          # measurements                                 [paper, Fig. 1/4]
TAU = 0.2       # prior correlation length                     [paper, Fig. 4]
DELTA = 0.001   # shrinkage on the diagonal                    [paper]
SIGMA = 1.0     # noise sd                                     [paper, Fig. 4]
BLUR = 0.2      # width of each measurement's averaging kernel [choice: paper's A not given]

rng = np.random.default_rng(SEED)

s = np.linspace(-1, 1, N)                  # grid of unknowns
cm = np.linspace(-1, 1, M)                 # measurement centres
# Each measurement is a Gaussian-weighted local average of x (rows sum to 1).
# Nearby rows overlap strongly, so A is numerically low rank, as in Fig. 1.
A = np.exp(-(s[None, :] - cm[:, None]) ** 2 / (2 * BLUR**2))
A /= A.sum(axis=1, keepdims=True)

C_pr = np.exp(-(s[:, None] - s[None, :]) ** 2 / (2 * TAU**2)) + DELTA * np.eye(N)
L = np.linalg.cholesky(C_pr)

# truth drawn from the prior, then data
Z_true = rng.standard_normal(N)
x_true = L @ Z_true
y = A @ x_true + SIGMA * rng.standard_normal(M)

# analytic posterior in the non-centred coordinates Z (x = L Z)
B = A @ L
cov_Z = np.linalg.inv(np.eye(N) + B.T @ B / SIGMA**2)
mean_Z = cov_Z @ B.T @ y / SIGMA**2
mean_x = L @ mean_Z
cov_x = L @ cov_Z @ L.T


def kappa(C):
    """Condition number of eq. (8) for a covariance C."""
    lam = np.sqrt(np.sort(np.linalg.eigvalsh(C))[::-1])
    return float(np.sum((lam[0] / lam) ** 4) ** 0.25)


data = dict(N=N, M=M, s=s.tolist(), A=A.tolist(), y=y.tolist(),
            sigma=SIGMA, tau=TAU, delta=DELTA)
truth = dict(seed=SEED, Z=Z_true.tolist(), x=x_true.tolist())
reference = dict(
    note="Exact Gaussian posterior. Z is the non-centred parameter, x = L_pr Z.",
    x_mean=mean_x.tolist(), x_sd=np.sqrt(np.diag(cov_x)).tolist(),
    Z_mean=mean_Z.tolist(), Z_sd=np.sqrt(np.diag(cov_Z)).tolist(),
    kappa_centered=kappa(cov_x), kappa_noncentered=kappa(cov_Z),
)

with open("plasma_linear.json", "w") as f:
    json.dump(data, f)
with open("plasma_linear_truth.json", "w") as f:
    json.dump(truth, f)
with open("plasma_linear_reference.json", "w") as f:
    json.dump(reference, f)

print(f"N={N} M={M} sigma={SIGMA} tau={TAU} delta={DELTA} blur={BLUR}")
print(f"singular values of A: max {np.linalg.svd(A, compute_uv=False).max():.2f}, "
      f"min {np.linalg.svd(A, compute_uv=False).min():.1e}")
print(f"kappa (eq. 8): centred {reference['kappa_centered']:.1f}, "
      f"non-centred {reference['kappa_noncentered']:.1f}")
