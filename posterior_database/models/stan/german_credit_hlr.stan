data {
  int<lower=0> N;
  int<lower=0> D;                 
  matrix[N, D] X;                 // main effects + pairwise interactions
  array[N] int<lower=0, upper=1> y;
}
parameters {
  real alpha;
  vector[D] beta;
  real<lower=0> sigma2;
}
model {
  sigma2 ~ exponential(0.01);
  alpha ~ normal(0, sqrt(sigma2));
  beta ~ normal(0, sqrt(sigma2));
  y ~ bernoulli_logit(alpha + X * beta);
}
