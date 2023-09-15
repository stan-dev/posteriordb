data {
  int<lower=0> N;
  int<lower=0> J;
  array[N] int<lower=1, upper=J> county_idx;
  vector[N] floor_measure;
  vector[N] log_radon;
}
parameters {
  real<lower=0> sigma_y;
  real<lower=0> sigma_alpha;
  real<lower=0> sigma_beta;
  vector[J] alpha_raw;
  vector[J] beta_raw;
  real mu_alpha;
  real mu_beta;
}
transformed parameters {
  vector[J] alpha;
  vector[J] beta;
  // implies: alpha ~ normal(mu_alpha, sigma_alpha);
  alpha = mu_alpha + sigma_alpha * alpha_raw;
  // implies: beta ~ normal(mu_beta, sigma_beta);
  beta = mu_beta + sigma_beta * beta_raw;
}
model {
  vector[N] mu;
  // Prior
  sigma_y ~ normal(0, 1);
  sigma_beta ~ normal(0, 1);
  sigma_alpha ~ normal(0, 1);
  mu_alpha ~ normal(0, 10);
  mu_beta ~ normal(0, 10);
  alpha_raw ~ normal(0, 1);
  beta_raw ~ normal(0, 1);
  
  // Likelihood
  for (n in 1 : N) {
    mu[n] = alpha[county_idx[n]] + floor_measure[n] * beta[county_idx[n]];
    target += normal_lpdf(log_radon[n] | mu[n], sigma_y);
  }
}


