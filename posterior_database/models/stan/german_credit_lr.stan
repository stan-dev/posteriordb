data {
  int<lower=0> N;
  int<lower=0> D;                 // 24
  matrix[N, D] X;                 // standardized predictors
  array[N] int<lower=0, upper=1> y;
}
parameters {
  real alpha;
  vector[D] beta;
}
model {
  alpha ~ normal(0, 10);          // variance 100
  beta ~ normal(0, 10);
  y ~ bernoulli_logit(alpha + X * beta);
}
