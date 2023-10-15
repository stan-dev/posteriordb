data {
  int<lower=0> J;
  int<lower=0> N;
  array[N] int<lower=1, upper=J> county_idx;
  vector[N] log_uppm;
  vector[N] floor_measure;
  vector[N] log_radon;
}
parameters {
  vector[J] alpha;
  vector[2] beta;
  real mu_alpha;
  real<lower=0> sigma_alpha;
  real<lower=0> sigma_y;
}
model {
  vector[N] mu;
  vector[N] muj;
  
  sigma_alpha ~ normal(0, 1);
  sigma_y ~ normal(0, 1);
  mu_alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  
  alpha ~ normal(mu_alpha, sigma_alpha);
  for (n in 1 : N) {
    muj[n] = alpha[county_idx[n]] + log_uppm[n] * beta[1];
    mu[n] = muj[n] + floor_measure[n] * beta[2];
    target += normal_lpdf(log_radon[n] | mu[n], sigma_y);
  }
}


