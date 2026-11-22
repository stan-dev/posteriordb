// Linear Gaussian toy version of the plasma model, centred ("direct") parameterization.
// Langmore et al. (2022), arXiv:2103.07515, eqs. (1)-(2) and Fig. 4.
//
//   x ~ N(0, C_pr),  y ~ N(A x, sigma^2 I)
//   C_pr[i, j] = exp(-(s_i - s_j)^2 / (2 tau^2)) + delta * 1{i = j}
//
// Same posterior as plasma_linear_noncentered.stan, but sampled directly in x.
// With the default data it is much worse conditioned (larger kappa), which is
// the paper's point in Fig. 4. Its log density differs from the non-centred
// model's by the constant log|det L_pr|.

data {
  int<lower=1> N;
  int<lower=1> M;
  vector[N] s;
  matrix[M, N] A;
  vector[M] y;
  real<lower=0> sigma;
  real<lower=0> tau;
  real<lower=0> delta;
}

transformed data {
  matrix[N, N] L_pr;
  {
    matrix[N, N] C;
    for (i in 1:N)
      for (j in 1:N)
        C[i, j] = exp(-square(s[i] - s[j]) / (2 * square(tau)));
    L_pr = cholesky_decompose(add_diag(C, delta));
  }
}

parameters {
  vector[N] x;
}

model {
  target += multi_normal_cholesky_lpdf(x | rep_vector(0, N), L_pr);
  target += normal_lpdf(y | A * x, sigma);
}
