data {
  int<lower=0> J;
  int<lower=0> N;
  array[N] int<lower=1, upper=J> county_idx;
  vector[N] floor_measure;
  vector[N] log_radon;
}
parameters {
  real alpha;
  vector[J] beta_raw;
  real mu_beta;
  real<lower=0> sigma_beta;
  real<lower=0> sigma_y;
}
transformed parameters {
  vector[J] beta;
  // implies: beta ~ normal(mu_beta, sigma_beta);
  beta = mu_beta + sigma_beta * beta_raw;
}
model {
  vector[N] mu;
  // Prior
  alpha ~ normal(0, 10);
  sigma_y ~ normal(0, 1);
  sigma_beta ~ normal(0, 1);
  mu_beta ~ normal(0, 10);
  beta_raw ~ normal(0, 1);
  
  for (n in 1 : N) {
    mu[n] = alpha + floor_measure[n] * beta[county_idx[n]];
    target += normal_lpdf(log_radon[n] | mu[n], sigma_y);
  }
}


