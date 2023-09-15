data {
  int<lower=0> n_dogs;
  int<lower=0> n_trials;
  array[n_dogs, n_trials] int<lower=0, upper=1> y;
}
transformed data {
  int<lower=0> J = n_dogs;
  int<lower=0> T = n_trials;
  matrix<lower=0>[J, T] prev_shock;
  matrix<lower=0>[J, T] prev_avoid;
  for (j in 1 : J) {
    prev_shock[j, 1] = 0;
    prev_avoid[j, 1] = 0;
    for (t in 2 : T) {
      prev_shock[j, t] = prev_shock[j, t - 1] + y[j, t - 1];
      prev_avoid[j, t] = prev_avoid[j, t - 1] + 1 - y[j, t - 1];
    }
  }
}
parameters {
  vector[2] mu_logit_ab;
  vector<lower=0>[2] sigma_logit_ab;
  cholesky_factor_corr[2] L_logit_ab;
  matrix[J, 2] z;
}
transformed parameters {
  matrix[J, 2] logit_ab = rep_vector(1, J) * mu_logit_ab'
                          + z * diag_pre_multiply(sigma_logit_ab, L_logit_ab);
  corr_matrix[2] Omega_logit_ab = L_logit_ab * L_logit_ab';
  cov_matrix[2] Sigma_logit_ab = quad_form_diag(Omega_logit_ab,
                                                sigma_logit_ab);
  vector[J] a = inv_logit(logit_ab[ : , 1]);
  vector[J] b = inv_logit(logit_ab[ : , 2]);
}
model {
  for (j in 1 : J) {
    for (t in 1 : T) {
      real p = a[j] ^ prev_shock[j, t] * b[j] ^ prev_avoid[j, t];
      y[j, t] ~ bernoulli(p);
    }
  }
  mu_logit_ab ~ logistic(0, 1);
  sigma_logit_ab ~ normal(0, 1);
  L_logit_ab ~ lkj_corr_cholesky(2);
  to_vector(z) ~ normal(0, 1);
}
generated quantities {
  array[J, T] int<lower=0, upper=1> y_rep;
  {
    real prev_shock_rep;
    real prev_avoid_rep;
    real p_rep;
    for (j in 1 : J) {
      prev_shock_rep = 0;
      prev_avoid_rep = 0;
      y_rep[j, 1] = 1;
      for (t in 2 : T) {
        prev_shock_rep = prev_shock_rep + y_rep[j, t - 1];
        prev_avoid_rep = prev_avoid_rep + 1 - y_rep[j, t - 1];
        p_rep = a[j] ^ prev_shock_rep * b[j] ^ prev_avoid_rep;
        y_rep[j, t] = bernoulli_rng(p_rep);
      }
    }
  }
}


