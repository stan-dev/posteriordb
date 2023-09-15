data {
  int<lower=1> K;
  int<lower=1> N;
  array[N] real y;
}
parameters {
  simplex[K] theta;
  array[K] real mu;
  array[K] real<lower=0, upper=10> sigma;
}
model {
  array[K] real ps;
  mu ~ normal(0, 10);
  for (n in 1 : N) {
    for (k in 1 : K) {
      ps[k] = log(theta[k]) + normal_lpdf(y[n] | mu[k], sigma[k]);
    }
    target += log_sum_exp(ps);
  }
}


