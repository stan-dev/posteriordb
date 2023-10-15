data {
  int<lower=0> N;
  int<lower=0> J;
  array[N] int<lower=1, upper=J> county_idx;
  vector[N] floor_measure;
  vector[N] log_radon;
}
parameters {
  vector[J] alpha;
  real beta;
  real<lower=0> sigma_y;
}
model {
  vector[N] mu;
  // Prior
  sigma_y ~ normal(0, 1);
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  
  // Likelihood
  for (n in 1 : N) {
    mu[n] = alpha[county_idx[n]] + beta * floor_measure[n];
    target += normal_lpdf(log_radon[n] | mu[n], sigma_y);
  }
}


