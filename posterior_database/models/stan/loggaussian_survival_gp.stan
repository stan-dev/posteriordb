functions {
  vector gp_pred_exp_quad_rng(vector[] x_pred,
                     vector y1, vector[] x,
                     real magnitude, real[] length_scale, real sigma) {
    int N1 = rows(y1);
    int N2 = size(x_pred);
    vector[N2] f2;
    {
      matrix[N1, N1] K =   gp_exp_quad_cov(x, magnitude, length_scale)
                         + diag_matrix(rep_vector(square(sigma), N1));
      matrix[N1, N1] L_K = cholesky_decompose(K);

      vector[N1] L_K_div_y1 = mdivide_left_tri_low(L_K, y1);
      vector[N1] K_div_y1 = mdivide_right_tri_low(L_K_div_y1', L_K)';
      matrix[N1, N2] k_x_x_pred = gp_exp_quad_cov(x, x_pred, magnitude, length_scale);
      vector[N2] f2_mu = (k_x_x_pred' * K_div_y1);
      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x_x_pred);
      matrix[N2, N2] cov_f2 =   gp_exp_quad_cov(x_pred, magnitude, length_scale) - v_pred' * v_pred
                              + diag_matrix(rep_vector(1e-6, N2));
      f2 = multi_normal_rng(f2_mu, cov_f2);
    }
    return f2;
  }
}
data {
  int<lower=1> N;
  int<lower=1> D;
  int<lower=1> N_pred;
  int<lower=1> n_events;
  int<lower=0> n_censored;
  vector[D] x[N];


  vector[D] x_male_age[N_pred];
  vector[D] x_female_age[N_pred];

  /* vector[D] x_male_tdi[N_pred]; */
  /* vector[D] x_female_tdi[N_pred]; */

  // vector[D] x_male_wbc[N_pred];
  // vector[D] x_female_wbc[N_pred];

  // vector[D] x_female_wbc_tdi1[N_pred];
  // vector[D] x_female_wbc_tdi6[N_pred];

  vector[N] y;                    // time for observation n
  vector[N] event;
  int event_idx[n_events];
  int censored_idx[n_censored];
}

transformed data {
  vector[N] y_new = y / exp(mean(log(y)));
}
parameters {
  real<lower=0> magnitude;
  real<lower=0> length_scale[D];
  real<lower=0> sig_0;
  real<lower=0> sigma;
  vector[N] eta;
}
transformed parameters {
  vector[N] f;
{
    matrix[N, N] L_K;
    //    matrix[N, N] K = gp_dot_prod_cov(x, sig_0) + gp_exp_quad_cov(x, magnitude, length_scale);
    matrix[N, N] K = gp_exp_quad_cov(x, magnitude, length_scale);
    K = add_diag(K, sigma);
    L_K = cholesky_decompose(K);
    f = L_K * eta;
  }
}
model {
  length_scale ~ gamma(2, 2);
  magnitude ~ normal(0, 2);
  sig_0 ~ normal(0, 2);
  sigma ~ normal(0, 1);
  eta ~ normal(0, 1);
  
  target += lognormal_lpdf(y[event_idx] | f[event_idx], sigma);
  target += lognormal_lccdf(y[censored_idx] | f[censored_idx], sigma);
}
generated quantities {
  vector[N_pred] f_male_age = gp_pred_exp_quad_rng(x_male_age, f, x,
                                          magnitude, length_scale, sigma);
  vector[N_pred] f_female_age = gp_pred_exp_quad_rng(x_female_age, f, x,
                                            magnitude, length_scale, sigma);

  /* vector[N_pred] f_male_tdi = gp_pred_rn(x_male_tdi, f, x, */
  /*                                        magnitude, length_scale, sigma); */

  vector[N_pred] y_male_age;
  vector[N_pred] y_female_age;
  /* vector[N_pred] y_male_tdi; */
  for (n in 1:N_pred) {
    y_male_age[n] = lognormal_rng(f_male_age[n], sigma);
    y_female_age[n] = lognormal_rng(f_female_age[n], sigma);
    /* y_male_tdi[n] = lognormal_rng(f_male_tdi[n], sigma); */
  }

  // vector[N_pred] f_male_tdi;
  // vector[N_pred] y_male_tdi;
  // vector[N_pred] f_female_tdi;
  // vector[N_pred] y_female_tdi;

  // vector[N_pred] f_male_wbc;
  // vector[N_pred] y_male_wbc;
  // vector[N_pred] f_female_wbc;
  // vector[N_pred] y_female_wbc;

  // vector[N_pred] f_female_wbc_tdi1;
  // vector[N_pred] y_female_wbc_tdi1;
  // vector[N_pred] f_female_wbc_tdi6;
  // vector[N_pred] y_female_wbc_tdi6;

  // f_male_age = gp_pred_exp_quad_rng(x_male_age, f, x, K, 1.0, 1.0, sigma, 1e-12);
  // f_female_age = gp_pred_exp_quad_rng(x_female_age, f, x, K, 1.0, 1.0, sigma, 1e-12);

  // f_male_tdi = gp_pred_exp_quad_rng(x_male_tdi, f, x, K, 1.0, 1.0, sigma, 1e-12);
  // f_female_tdi = gp_pred_exp_quad_rng(x_female_tdi, y, x, K, 1.0, 1.0, sigma, 1e-12);

  // f_male_wbc = gp_pred_exp_quad_rng(x_male_wbc, f, x, K, 1.0, 1.0, sigma, 1.0, 1e-12);
  // f_female_wbc = gp_pred_exp_quad_rng(x_female_wbc, f, x, K, 1.0.0, 1.0, sigma, 1e-12);

  // f_female_wbc_tdi1.0 = gp_pred_exp_quad_rng(x_female_wbc_tdi, 1.0, f, x, K, 1.0, 1.0, sigma, 1.0, 1e-12);
  // f_female_wbc_tdi6 = gp_pred_exp_quad_rng(x_female_wbc_tdi6, f, x, K, 1.0, 1.0, sigma, 1e-12);
}
