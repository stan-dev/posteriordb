data {
  int<lower=0> N;              // observations (Full MNIST: 60K)
  int<lower=0> M;              // predictors   (MNIST: 784)
  matrix[N, M] x;              // data matrix  (Full MNIST: 60K x 784 = 47M)
  int<lower=2> K;              // number of categories (MNIST: 10)
  int<lower=1, upper=K> y[N];  // categories
}

transformed data{
  int<lower=1> J = 100; // number of hidden units (e.g. 100)

  // prior parametrization in Lampainen and Vehtari (2001)
  real nu_alpha = 0.5;
  real s2_0_alpha = (0.05 / M^(1/nu_alpha))^2;
  real nu_beta = 0.5;
  real s2_0_beta = (0.05 / J^(1/nu_beta))^2;

  vector[N] ones = rep_vector(1, N);
  matrix[N, M + 1] x1 = append_col(ones, x);
}

parameters {
  matrix[M + 1, J] alpha;
  matrix[J + 1, K - 1] beta;
  real<lower=0> sigma_alpha2;
  real<lower=0> sigma_beta2;
}

model {
  matrix[N, K] v = append_col(ones, (append_col(ones, tanh(x1 * alpha)) * beta));

  // Prior
  sigma_alpha2 ~ inv_gamma(nu_alpha / 2, nu_alpha * s2_0_alpha / 2);
  sigma_beta2 ~ inv_gamma(nu_beta / 2, nu_beta * s2_0_beta / 2);

  to_vector(alpha) ~ normal(0, sqrt(sigma_alpha2));
  to_vector(beta) ~ normal(0, sqrt(sigma_beta2));
  for (n in 1:N)
    y[n] ~ categorical_logit(v[n]');
}
