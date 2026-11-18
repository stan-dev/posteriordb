// Plasma "shell" model: spectroscopic tomography with a radially symmetric,
// randomly shifted-centre profile for amplitude, temperature and velocity.
// Langmore, Dikovsky, Geraedts, Norgaard, von Behren (2022), arXiv:2103.07515, sec. 2.3.
//
// Choices NOT fixed by the paper (must match the PyMC version):
//   * profile prior covariance:  exp(-|r-r'|^2 / (2 tau^2)) + delta * I   (delta on the diagonal only)
//   * one centre shared by A, T and V, centre ~ N(0, sigma_c^2 I)
//   * piecewise-linear interpolation of radial profiles, constant beyond the grid ends
//   * sigma and sigma_p are fixed data, not inferred
//   * w = sqrt(T) / nu_0, as printed in the paper
// The full normalised density is used (target += ...), so log_prob is directly
// comparable with PyMC's model.logp().

functions {
  // Piecewise-linear interpolation on an ascending grid; constant outside it.
  real interp_lin(real r, vector grid, vector vals) {
    int n = rows(grid);
    if (r <= grid[1]) return vals[1];
    if (r >= grid[n]) return vals[n];
    int lo = 1;
    int hi = n;
    while (hi - lo > 1) {
      int mid = (lo + hi) %/% 2;
      if (grid[mid] <= r) lo = mid; else hi = mid;
    }
    real t = (r - grid[lo]) / (grid[hi] - grid[lo]);
    return (1 - t) * vals[lo] + t * vals[hi];
  }

  // Noise-free chord spectra (M x K) for given radial profiles and centre.
  matrix mu_fn(vector fA, vector fT, vector fV, vector ctr,
               matrix xy, vector r_grid, vector nu_inv, real nu_0,
               matrix I_mat, real c_A, real c_T, real c_V) {
    int P = rows(xy);
    int K = rows(nu_inv);
    vector[P] A;
    vector[P] Temp;
    vector[P] V;
    for (p in 1:P) {
      // 1e-12 keeps the gradient finite if a pixel sits exactly on the centre
      real r = sqrt(square(xy[p, 1] - ctr[1]) + square(xy[p, 2] - ctr[2]) + 1e-12);
      A[p]    = c_A * log1p_exp(interp_lin(r, r_grid, fA));   // softplus
      Temp[p] = c_T * log1p_exp(interp_lin(r, r_grid, fT));   // softplus
      V[p]    = c_V * interp_lin(r, r_grid, fV);
    }
    vector[P] w = sqrt(Temp) / nu_0;
    vector[P] pref = A ./ (sqrt(2 * pi()) * w);
    vector[P] inv_2w2 = inv(2 * square(w));
    vector[P] nu_tilde_inv = (1 - V) / nu_0;   // = 1 / nu_tilde, no singularity at V = 1
    matrix[P, K] emis;
    for (k in 1:K)
      emis[, k] = pref .* exp(-square(nu_inv[k] - nu_tilde_inv) .* inv_2w2);
    return I_mat * emis;
  }
}

data {
  int<lower=1> P;                    // pixels
  int<lower=1> M;                    // chords
  int<lower=1> K;                    // frequencies
  int<lower=2> R;                    // radial nodes

  vector<lower=0>[K] nu;
  real<lower=0> nu_0;
  matrix<lower=0>[M, P] I_mat;       // chord integration matrix
  matrix[M, K] Y;
  matrix[P, 2] xy;                   // pixel coordinates
  vector<lower=0>[R] r_grid;         // strictly ascending radial nodes

  real<lower=0> tau;                 // prior correlation length
  real<lower=0> delta;               // shrinkage on the diagonal
  real<lower=0> sigma_c;             // sd of the centre prior

  real<lower=0> c_A;
  real<lower=0> c_T;
  real c_V;
  real<lower=0> sigma;               // additive noise sd
  real<lower=0> sigma_p;             // proportional noise (model error)
}

transformed data {
  vector[K] nu_inv = inv(nu);
  matrix[R, R] L_pr;
  for (i in 2:R)
    if (r_grid[i] <= r_grid[i - 1])
      reject("r_grid must be strictly ascending");
  {
    matrix[R, R] C;
    for (i in 1:R)
      for (j in 1:R)
        C[i, j] = exp(-square(r_grid[i] - r_grid[j]) / (2 * square(tau)));
    L_pr = cholesky_decompose(add_diag(C, delta));
  }
}

parameters {
  vector[R] Z_A;       // non-centred radial profiles
  vector[R] Z_T;
  vector[R] Z_V;
  vector[2] c_raw;     // standardised centre
}

transformed parameters {
  vector[2] ctr = sigma_c * c_raw;
  vector[R] fA = L_pr * Z_A;     // X_tilde: correlated radial profiles
  vector[R] fT = L_pr * Z_T;
  vector[R] fV = L_pr * Z_V;
}

model {
  matrix[M, K] mu = mu_fn(fA, fT, fV, ctr, xy, r_grid, nu_inv, nu_0,
                          I_mat, c_A, c_T, c_V);
  matrix[M, K] sd_Y = sqrt(square(sigma) + square(sigma_p) * square(mu));

  target += std_normal_lpdf(Z_A) + std_normal_lpdf(Z_T) + std_normal_lpdf(Z_V)
            + std_normal_lpdf(c_raw);
  target += normal_lpdf(to_vector(Y) | to_vector(mu), to_vector(sd_Y));
}
