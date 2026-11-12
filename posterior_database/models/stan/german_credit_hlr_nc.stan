data {
  int<lower=0> N;
  int<lower=0> D;                 
  matrix[N, D] X;                 // main effects + pairwise interactions
  array[N] int<lower=0, upper=1> y;
}
parameters {
  real alpha_raw;
  vector[D] beta_raw;
  real<lower=0> sigma2;
}
transformed parameters {
  real<lower=0> sigma = sqrt(sigma2);
  real alpha = sigma * alpha_raw;
  vector[D] beta = sigma * beta_raw;
}
model {
  sigma2 ~ exponential(0.01);
  alpha_raw ~ std_normal();
  beta_raw ~ std_normal();
  y ~ bernoulli_logit(alpha + X * beta);
}
