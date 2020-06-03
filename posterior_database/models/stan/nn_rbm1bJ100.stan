data {
  int<lower=0> N;              // observations (Full MNIST: 60K)
  int<lower=0> M;              // predictors   (MNIST: 784)
  matrix[N, M] x;              // data matrix  (Full MNIST: 60K x 784 = 47M)
  int<lower=2> K;              // number of categories (MNIST: 10)
  int<lower=1, upper=K> y[N];  // categories
}

transformed data{
  int<lower=1> J = 100; // number of hidden units
  vector[N] ones = rep_vector(1, N);
  matrix[N, M + 1] x1 = append_col(ones, x);
}

parameters {
  matrix[M + 1, J] alpha;
  matrix[J + 1, K - 1] beta;
  real<lower=0> sigma_alpha;
  real<lower=0> sigma_beta;
}

model {
  matrix[N, K] v = append_col(ones, (append_col(ones, tanh(x1 * alpha)) * beta));

  // Prior
  sigma_alpha ~ inv_gamma((0.05 / M^2)^2, 0.5);
  sigma_beta ~ inv_gamma((0.05 / J^2)^2, 0.5);

  to_vector(alpha) ~ normal(0, sigma_alpha);
  to_vector(beta) ~ normal(0, sigma_beta);
  for (n in 1:N)
    y[n] ~ categorical_logit(v[n]');
}
