data {
  int<lower=1> N;
  int<lower=1> D;
  
  vector[D] x[N];
  vector[N] y;
}
transformed data {
  vector[N] mu;
  mu = rep_vector(0, N);
}
parameters {
  real<lower=0> magnitude;
  real<lower=0> length_scale[D];
}
model {
  matrix[N, N] L_K;
  {
    matrix[N, N] K;
    K = cov_exp_quad(x, magnitude, length_scale);
    for (n in 1:N)
      K[n, n] = K[n, n] + 1e-6;
    L_K = cholesky_decompose(K);
  }
  y ~ multi_normal_cholesky(mu, L_K);
}