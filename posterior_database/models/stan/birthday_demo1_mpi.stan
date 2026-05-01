functions {
  matrix gp(real[] x, vector params) {
    int N = size(x);
    matrix[N, N] K = gp_exp_quad_cov(x, params[1], params[2]) +

      gp_periodic_cov(x, params[3], params[4], 7.0) .*
      gp_exp_quad_cov(x, 1.0, params[5]);
    for (n in 1:N) K[n, n] = K[n, n] + 1e-6;
    return K;
  }
}
data {
  int<lower=1> N;
  real xn[N];
  vector[N] yn;
}
transformed data {
  vector[N] mu = rep_vector(0, N);
}
parameters {
  // kernel 1, smooth non-periodic component
  real<lower=0> length_scale_1;
  real<lower=0> magnitude_1;

  // kernel 2, periodic component
  real<lower=0> length_scale_2_1;
  real<lower=0> magnitude_2;
  real<lower=0> length_scale_2_2;
}
transformed parameters {
  real<lower=0> params[5];
  matrix[N, N] L_K;
  params[1] = length_scale_1;
  params[2] = magnitude_1;
  params[3] = length_scale_2_1;
  params[4] = magnitude_2;
  params[5] = length_scale_2_2;
  {
    // L_K = cholesky_decompose(K);
  }
}
model {

  // kernel 1 priors
  length_scale_1 ~ lognormal(log(10), log(2)); // may be second parameter is wrong??
  magnitude_1 ~ lognormal(log(1), log(2));

  // kernel 2 priors
  length_scale_2_1 ~ lognormal(log(2), log(2));
  magnitude_2 ~ lognormal(log(.5), log(2));
  length_scale_2_2 ~ lognormal(log(20), log(2));

  //  yn ~ multi_normal_cholesky(mu, L_K);
}
