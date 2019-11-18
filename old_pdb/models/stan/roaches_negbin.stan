data {
  int<lower=0> N;
  vector[N] exposure2;
  vector[N] roach1;
  vector[N] senior;
  vector[N] treatment;
  int y[N];
}
transformed data {
  vector[N] log_expo;
  log_expo = log(exposure2);
}
parameters {
  vector[4] beta;
  real phi;
}
model {
  // prior
  phi ~ cauchy(0, 5);
  beta ~ normal(0, 10);

  // likelihood
  y ~ neg_binomial_2_log(log_expo + beta[1] + beta[2] * roach1 + beta[3] * treatment + beta[4] * senior, phi);
}
