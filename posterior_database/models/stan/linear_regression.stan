data {
  int<lower=1> N;
  int<lower=1> D;
  matrix[N, D] x;
  vector[N] y;

  /* int<lower=1> N_pred; */
  /* matrix[N_pred, D] x_pred; */
}
parameters {
  real alpha;
  vector[D] beta;
  real<lower=0> sigma;
}
model {
  alpha ~ normal(0, 1);                 // intercept prior
  beta ~ normal(0, 1);                  // regression coef priors
  sigma ~ normal(0, 1);                 // model noise

  y ~ normal(alpha + x * beta, sigma);  // likelihood function
}
generated quantities {
  /* vector[N_pred] y_pred; */
  /* for (n in 1:N_pred) y_pred[n] = normal_rng(alpha + x_pred[n] * beta, sigma); */
}
