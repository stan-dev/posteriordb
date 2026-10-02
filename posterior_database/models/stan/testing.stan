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
    K = cov_exp_quad(x[,1:6], magnitude, length_scale);
  }
      //  y ~ multi_normal_cholesky(mu, L_K);
}
