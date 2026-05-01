data {
  int<lower=1> N;
  real x[N];

  real<lower=0> length_scale;
  real<lower=0> magnitude;
  real<lower=0> sigma;
}

transformed data {
  matrix[N, N] cov =   add_diag(gp_exponetial_cov(x, magnitude, length_scale), 1e-10);
  matrix[N, N] L_cov = cholesky_decompose(cov);
}
parameters {}
model {}
generated quantities {
  vector[N] f = multi_normal_cholesky_rng(rep_vector(0, N), L_cov);
  vector[N] y;
  for (n in 1:N)
    y[n] = normal_rng(f[n], sigma);
}
