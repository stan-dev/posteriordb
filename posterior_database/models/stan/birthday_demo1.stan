functions {
  vector gp_pred_exp_quad_rng(real[] x2,
                              vector y, real[] x1,
                              real magnitude_1, real length_scale_1,
                              real magnitude_2, real length_scale_2_1,
                              real length_scale_2_2, real period,
                              real sigma) {
    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = add_diag(gp_exp_quad_cov(x1, magnitude_1, length_scale_1) +
                                  gp_periodic_cov(x1, magnitude_2, length_scale_2_1, period) .*
                                  gp_exp_quad_cov(x1, 1.0, length_scale_2_2), sigma);
      matrix[N1, N1] L_K = cholesky_decompose(K);
      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_exp_quad_cov(x1, x2, magnitude_1, length_scale_1);
      f = (k_x1_x2' * K_div_y);
    }
    return f;
  }
  vector gp_pred_periodic_exp_quad_rng(real[] x2,
                                       vector y, real[] x1,
                                       real magnitude_1, real length_scale_1,
                                       real magnitude_2, real length_scale_2_1,
                                       real length_scale_2_2, real period,
                                       real sigma) {
    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = add_diag(gp_exp_quad_cov(x1, magnitude_1, length_scale_1) +
                                  gp_periodic_cov(x1, magnitude_2, length_scale_2_1, period) .*
                                  gp_exp_quad_cov(x1, 1.0, length_scale_2_2), sigma);
      matrix[N1, N1] L_K = cholesky_decompose(K);
      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_periodic_cov(x1, x2, magnitude_2, length_scale_2_1, period) .*
                               gp_exp_quad_cov(x1, x2,  1.0, length_scale_2_2);
      f = (k_x1_x2' * K_div_y);
    }
    return f;
  }
  vector gp_pred_full_rng(real[] x2,
                                       vector y, real[] x1,
                                       real magnitude_1, real length_scale_1,
                                       real magnitude_2, real length_scale_2_1,
                                       real length_scale_2_2, real period,
                                       real sigma) {
    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = add_diag(gp_exp_quad_cov(x1, magnitude_1, length_scale_1) +
                                  gp_periodic_cov(x1, magnitude_2, length_scale_2_1, period) .*
                                  gp_exp_quad_cov(x1, 1.0, length_scale_2_2), sigma);
      matrix[N1, N1] L_K = cholesky_decompose(K);
      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_periodic_cov(x1, x2, magnitude_2, length_scale_2_1, period) .*
        gp_exp_quad_cov(x1, x2,  1.0, length_scale_2_2) +
        gp_exp_quad_cov(x1, 1.0, length_scale_2_2);
      f = (k_x1_x2' * K_div_y);
    }
    return f;
  }
}
data {
  int<lower=1> N;
  real xn[N];
  vector[N] yn;
}
transformed data {
  vector[N] mu = rep_vector(0, N);
}
parameters {
  // kernel 1, smooth non-periodic component
  real<lower=0> length_scale_1;
  real<lower=0> magnitude_1;

  // kernel 2, periodic component
  real<lower=0> length_scale_2_1;
  real<lower=0> magnitude_2;
  real<lower=0> length_scale_2_2;
  real<lower=0> period;
  
  real sigma;
}
transformed parameters {
  matrix[N, N] L_K;
  {
  matrix[N, N] K = gp_exp_quad_cov(xn, magnitude_1, length_scale_1) +
                  gp_periodic_cov(xn, magnitude_2, length_scale_2_1, period) .*
                  gp_exp_quad_cov(xn, 1.0, length_scale_2_2);
  K = add_diag(K, sigma);
  L_K = cholesky_decompose(K);
  }
}
model {
  // kernel 1 priors
  length_scale_1 ~ lognormal(log(10), log(2));
  magnitude_1 ~ lognormal(log(1), log(2));

  // kernel 2 priors
  length_scale_2_1 ~ lognormal(log(2), log(2));
  magnitude_2 ~ lognormal(log(.05), log(2));
  length_scale_2_2 ~ lognormal(log(20), log(2));
  period ~ normal(7, .01);
  
  sigma ~ normal(0, 1);
  
  yn ~ multi_normal_cholesky(mu, L_K);
}
generated quantities {
  vector[N] f1_pred = gp_pred_exp_quad_rng(xn, yn, xn, magnitude_1, length_scale_1,
                                           magnitude_2, length_scale_2_1,
                                           length_scale_2_2, period, sigma); 
  vector[N] f2_pred = gp_pred_periodic_exp_quad_rng(xn, yn, xn, magnitude_1, length_scale_1,
                                                    magnitude_2, length_scale_2_1,
                                                    length_scale_2_2, period, sigma);
}
 
