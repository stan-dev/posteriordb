functions {
  vector gp_pred_exp_quad_rng(real[] x2,
                              vector y, real[] x1,
                              vector[] I_s, vector[] I_ss, vector[] I_ws,
                              real mag, real len,

                              real magnitude_1, real length_scale_1,
                              real magnitude_2, real length_scale_2,

                              real magnitude_3, real length_scale_3_1,
                              real length_scale_3_2,

                              real magnitude_4, real length_scale_4_1,
                              real length_scale_4_2,

                              real magnitude_5_1, real magnitude_5_2, real magnitude_5_3,
                              real jitter) {
    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = cov_exp_quad(x1, magnitude_1, length_scale_1) +
                   cov_exp_quad(x1, magnitude_2, length_scale_2) + 
                   gp_periodic_cov(x1, magnitude_3, length_scale_3_1, 7) .*
                      cov_exp_quad(x1, 1.0, length_scale_3_2) +
                   gp_periodic_cov(x1, magnitude_4, length_scale_4_1, 365.25) .*
                       cov_exp_quad(x1, 1.0, length_scale_4_2) + 
                   gp_dot_prod_cov(I_s, magnitude_5_1) +
                   gp_dot_prod_cov(I_ss, magnitude_5_2) +
                   gp_dot_prod_cov(I_ws, magnitude_5_3) + diag_matrix(rep_vector(jitter, N2));
      matrix[N1, N1] L_K = cholesky_decompose(K);
      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = cov_exp_quad(x1, x2, mag, len);
      vector[N2] f_mu = (k_x1_x2' * K_div_y);
      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      matrix[N2, N2] cov_f =   cov_exp_quad(x2, mag, len) - v_pred' * v_pred
                              + diag_matrix(rep_vector(jitter, N2));
      /* vector[N2] temp; */
      /* matrix[N2, N2] cov_f_diag; */
      /* for (n2 in 1:N2) */
      /*   temp[n2] = cov_f[n2, n2]; */
      /* cov_f_diag = diag_matrix(temp); */
      /* f = multi_normal_rng(f_mu, cov_f_diag); */
      f = f_mu;
    }
    return f;
  }
///////////////////////////
// periodic + squared exponential prediction,
// for kernels 3 and 4 in the sum
  vector gp_pred_periodic_exp_quad_rng(real[] x2,
                                       vector y, real[] x1,
                                       vector[] I_s, vector[] I_ss, vector[] I_ws,

                                       real mag_2, real len_2,
                                       real mag_3, real len_3_1, real len_3_2,
                                       real period,
                                       
                                       real magnitude_1, real length_scale_1,
                                       real magnitude_2, real length_scale_2,

                                       real magnitude_3, real length_scale_3_1,
                                       real length_scale_3_2,

                                       real magnitude_4, real length_scale_4_1,
                                       real length_scale_4_2,

                                       real magnitude_5_1, real magnitude_5_2, real magnitude_5_3,

                                       real jitter) {
    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = cov_exp_quad(x1, magnitude_1, length_scale_1) +
                   cov_exp_quad(x1, magnitude_2, length_scale_2) + 
                   gp_periodic_cov(x1, magnitude_3, length_scale_3_1, 7) .*
                      cov_exp_quad(x1, 1.0, length_scale_3_2) +
                   gp_periodic_cov(x1, magnitude_4, length_scale_4_1, 365.25) .*
                       cov_exp_quad(x1, 1.0, length_scale_4_2) + 
                   gp_dot_prod_cov(I_s, magnitude_5_1) +
                   gp_dot_prod_cov(I_ss, magnitude_5_2) +
                   gp_dot_prod_cov(I_ws, magnitude_5_3) + + diag_matrix(rep_vector(jitter, N2));
      matrix[N1, N1] L_K = cholesky_decompose(K);

      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_periodic_cov(x1, x2, mag_3, len_3_1, period) .*
                               cov_exp_quad(x1, x2,  mag_2, len_2);
      vector[N2] f_mu = (k_x1_x2' * K_div_y);

      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      matrix[N2, N2] cov_f =   gp_periodic_cov(x2, mag_3, len_3_1, period) .*
                               cov_exp_quad(x2,  mag_2, len_2) - v_pred' * v_pred
                              + diag_matrix(rep_vector(jitter, N2));
   
      /* vector[N2] temp; */
      /* matrix[N2, N2] cov_f_diag; */
      /*       f_mu = (k_x1_x2' * K_div_y); */
      /* for (n2 in 1:N2) */
      /*   temp[n2] = cov_f[n2, n2]; */
      /* cov_f_diag = diag_matrix(temp); */
 
      /* f = multi_normal_rng(f_mu, cov_f_diag); */
      f = f_mu;
    }
    return f;
  }
///////////////////////////
  vector gp_pred_dot_prod_rng(real[] x2,
                              vector y, real[] x1,
                              vector[] I_s, vector[] I_ss, vector[] I_ws,

                              real sig,

                              real magnitude_1, real length_scale_1,
                              real magnitude_2, real length_scale_2,

                              real magnitude_3, real length_scale_3_1,
                              real length_scale_3_2,

                              real magnitude_4, real length_scale_4_1,
                              real length_scale_4_2,

                              real magnitude_5_1, real magnitude_5_2, real magnitude_5_3,
                              real jitter) {
    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = cov_exp_quad(x1, magnitude_1, length_scale_1) +
                   cov_exp_quad(x1, magnitude_2, length_scale_2) + 
                   gp_periodic_cov(x1, magnitude_3, length_scale_3_1, 7) .*
                      cov_exp_quad(x1, 1.0, length_scale_3_2) +
                   gp_periodic_cov(x1, magnitude_4, length_scale_4_1, 365.25) .*
                       cov_exp_quad(x1, 1.0, length_scale_4_2) + 
                   gp_dot_prod_cov(I_s, magnitude_5_1) +
                   gp_dot_prod_cov(I_ss, magnitude_5_2) +
                   gp_dot_prod_cov(I_ws, magnitude_5_3) + diag_matrix(rep_vector(jitter, N2));
      matrix[N1, N1] L_K = cholesky_decompose(K);
      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_dot_prod_cov(x1, x2, sig);
      vector[N2] f_mu = (k_x1_x2' * K_div_y);

      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      matrix[N2, N2] cov_f =   gp_dot_prod_cov(x2, sig) - v_pred' * v_pred
                              + diag_matrix(rep_vector(jitter, N2));
      /* vector[N2] temp; */
      /* matrix[N2, N2] cov_f_diag; */
      /* for (n2 in 1:N2) */
      /*   temp[n2] = cov_f[n2, n2]; */
      /* cov_f_diag = diag_matrix(temp); */
 
      //      f = multi_normal_rng(f_mu, cov_f_diag);
      f = f_mu;
    }
    return f;
  }
}
///////////////////////////
data {
  int<lower=1> N;
  int<lower=1> N_pred;
  int M;
  real x[N];
  vector[N] y;

  // for the weekends and special days
  vector[M] I_s[N];
  vector[M] I_ss[N];
  vector[M] I_ws[N];
  real x_pred[N_pred];
}
transformed data {
  vector[N] mu = rep_vector(0, N);
}
parameters {
  //  f_1(t), squared exponential
  real<lower=0> length_scale_1;
  real<lower=0> magnitude_1;

 //   f_2(t), squared exponential
 real<lower=0> length_scale_2;
 real<lower=0> magnitude_2; 

  //  f_3(t), weekly quasi-periodic
 real<lower=0> length_scale_3_1;
 real<lower=0> magnitude_3_1;
 real<lower=0> length_scale_3_2;

  //  f_4(t), yearly smooth seasonal
  real<lower=0> length_scale_4_1;
  real<lower=0> magnitude_4_1;
  real<lower=0> length_scale_4_2;

  //  f_5(t), indicators for weekends and special days
  real<lower=0> magnitude_5_1;
  real<lower=0> magnitude_5_2;
  real<lower=0> magnitude_5_3;
}
transformed parameters {
   matrix[N, N] L_k;
   {
   matrix[N, N] k = cov_exp_quad(x, magnitude_1, length_scale_1) +
                   cov_exp_quad(x, magnitude_2, length_scale_2) + 
                   gp_periodic_cov(x, magnitude_3_1, length_scale_3_1, 7) .*
                      cov_exp_quad(x, 1.0, length_scale_3_2) +
                   gp_periodic_cov(x, magnitude_4_1, length_scale_4_1, 365.25) .*
                       cov_exp_quad(x, 1.0, length_scale_4_2) + 
                   gp_dot_prod_cov(I_s, magnitude_5_1) +
                   gp_dot_prod_cov(I_ss, magnitude_5_2) +
                   gp_dot_prod_cov(I_ws, magnitude_5_3);
  for (n in 1:N)
    k[n, n] = k[n, n] + 1e-12;
  L_k = cholesky_decompose(k);
  }
}
model {
//  matrix[N, N] L_k;
//  L_k = cholesky_decompose(k);

  // smooth non-periodic component
  length_scale_1 ~ lognormal(log(365), 1);
  magnitude_1 ~ normal(0, 1);

  // faster changing non-periodic component
  length_scale_2 ~ lognormal(log(10), 1);
  magnitude_2 ~ normal(0, 1);

  // 7 day period
  length_scale_3_1 ~ lognormal(log(2), sqrt(2));
  magnitude_3_1 ~ normal(0, 1);
  length_scale_3_2 ~ lognormal(log(20), 1);

  // 365.25 day period
  length_scale_4_1 ~ lognormal(log(100), sqrt(2));
  magnitude_4_1 ~ normal(0, 1);
  length_scale_4_2 ~ lognormal(log(1000), sqrt(2));

  magnitude_5_1 ~ normal(0, 1);
  magnitude_5_2 ~ normal(0, 1);
  magnitude_5_3 ~ normal(0, 1);
  
  y ~ multi_normal_cholesky(mu, L_k);
}
///////////////////////////
generated quantities {

  // f1 predictive        
  vector[N_pred] f1_pred;
  vector[N_pred] y1_pred;
  // f2 predictive
  vector[N_pred] f2_pred;
  vector[N_pred] y2_pred;
  // f3 predictive
  vector[N_pred] f3_pred;
  vector[N_pred] y3_pred;
  // f4 predictive
  vector[N_pred] f4_pred;
  vector[N_pred] y4_pred;
  // f5_1 predictive
  vector[N_pred] f5_pred;
  vector[N_pred] y5_pred;
 
  // f1 predictive
  f1_pred = gp_pred_exp_quad_rng(x_pred, y, x,
                                 I_s, I_ss, I_ws,

                                 magnitude_1, length_scale_1,

                                 1.0,  length_scale_1,
                                 magnitude_2,  length_scale_2,

                                 magnitude_3_1,  length_scale_3_1,
                                 length_scale_3_2,

                                 magnitude_4_1,  length_scale_4_1,
                                 length_scale_4_2,

                                 magnitude_5_1,  magnitude_5_2,  magnitude_5_3,

                                 1e-6);

  // f2 predictive
  f2_pred = gp_pred_exp_quad_rng(x_pred, y, x,
                                 I_s, I_ss, I_ws,

                                 magnitude_2, length_scale_2,

                                 magnitude_1,  length_scale_1,
                                 magnitude_2,  length_scale_2,

                                 magnitude_3_1,  length_scale_3_1,
                                 length_scale_3_2,

                                 magnitude_4_1,  length_scale_4_1,
                                 length_scale_4_2,

                                 magnitude_5_1,  magnitude_5_2,  magnitude_5_3,

                                 1e-6);

  // f3 predictive
  f3_pred = gp_pred_periodic_exp_quad_rng(x_pred, y, x,
                                          I_s, I_ss, I_ws,

                                          magnitude_2,  length_scale_2,
                                          1.0,  length_scale_3_1,  length_scale_3_2,
                                          7.0,
                                          
                                          magnitude_1,  length_scale_1,
                                          magnitude_2,  length_scale_2,

                                          magnitude_3_1,  length_scale_3_1,
                                          length_scale_3_2,

                                          magnitude_4_1,  length_scale_4_1,
                                          length_scale_4_2,

                                          magnitude_5_1,  magnitude_5_2,  magnitude_5_3,
                                          1e-6);
  // f4 predictive
  f4_pred = gp_pred_periodic_exp_quad_rng(x_pred, y, x,
                                          I_s, I_ss, I_ws,
                                          
                                          magnitude_2,  length_scale_2,
                                          1.0,  length_scale_3_1,  length_scale_3_2,
                                          365.25,
                                          
                                          magnitude_1,  length_scale_1,
                                          magnitude_2,  length_scale_2,

                                          magnitude_3_1,  length_scale_3_1,
                                          length_scale_3_2,

                                          magnitude_4_1,  length_scale_4_1,
                                          length_scale_4_2,

                                          magnitude_5_1,  magnitude_5_2,  magnitude_5_3,
                                          1e-6);
  // f5 predictive
  f5_pred = gp_pred_dot_prod_rng(x_pred, y, x,
                                 I_s, I_ss, I_ws,
                                 
                                 magnitude_5_1 + magnitude_5_2 + magnitude_5_3,

                                 magnitude_1,  length_scale_1,
                                 magnitude_2,  length_scale_2,

                                 magnitude_3_1,  length_scale_3_1,
                                 length_scale_3_2,

                                 magnitude_4_1,  length_scale_4_1,
                                 length_scale_4_2,

                                 magnitude_5_1,  magnitude_5_2,  magnitude_5_3,
                                 1e-6);

  for (n in 1:N_pred)
  {
    y1_pred[n] = normal_rng(f1_pred[n], 1.0);
    y2_pred[n] = normal_rng(f2_pred[n], 1.0);
    y3_pred[n] = normal_rng(f3_pred[n], 1.0);
    y4_pred[n] = normal_rng(f3_pred[n], 1.0);
    y5_pred[n] = normal_rng(f5_pred[n], 1.0);
   }
}
