// Bayesian Cox model with shared Gaussian frailty (McGilchrist & Aisbett, 1991)
// Requires data sorted by ascending time t.
data {
  int<lower=1> M, N, P;                  // # of patients, total obs, # of covariates
  vector[N] t;                           // gap times, sorted ascending
  array[N] int<lower=0, upper=1> D;      // 1 = uncensored, 0 = censored
  array[N] int<lower=1, upper=M> pid;    // patient_id for each interval
  matrix[N, P] X;                        // covariates- age,sex,disease type
  real<lower=0> sigma;                   // fixed log-frailty sd
}
parameters {
  vector[P] beta;                        // regression coeffs
  sum_to_zero_vector[M] u;               // log-frailties restriction [1'u = 0]
}
transformed parameters {
  vector[N] eta = X * beta + u[pid];     // linear substitution
}
model {
  // Priors
  u ~ normal(0, sigma);                  // log-frailties ~ normal(0, sigma^2)

  // Cox's partial likelihood: numerator sums the patient's intervals still at risk
  for (k in 1:N)
    if (D[k] == 1) {
      real num = negative_infinity();
      for (j in k:N)
        if (pid[j] == pid[k])
          num = log_sum_exp(num, eta[j]);
      target += num - log_sum_exp(eta[k:N]);
    }
}
generated quantities {
  vector[M] Z = exp(u);                  // Frailties
  real sigma2 = dot_self(u) / (M - 1);   // sigma^2 = u'u/(M-1)
}


