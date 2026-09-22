functions {
  vector gp_pred_exp_quad_rng(real[] x2,
                     vector y, real[] x1,
                     matrix k,
                     real magnitude, real length_scale, real sigma,                 // squared exp params + model noise
                     real jitter) {      
    // x2:            test data
    // x1:            training data
    // magnitude:        magnitude of squared exponential kernel
    // length_scale:  length_scale of squared exponential kernel
    // sigma:         model noise
    // jitter:        for numerical stability for inverse, etc.

    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = k;// + diag_matrix(rep_vector(square(sigma), N1));
      matrix[N1, N1] L_K = cholesky_decompose(K);

      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = cov_exp_quad(x1, x2, magnitude, length_scale);
      vector[N2] f_mu = (k_x1_x2' * K_div_y);

      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      matrix[N2, N2] cov_f =   cov_exp_quad(x2, magnitude, length_scale) - v_pred' * v_pred
                              + diag_matrix(rep_vector(jitter, N2));
      vector[N2] temp;
      matrix[N2, N2] cov_f_diag;
      for (n2 in 1:N2)
        temp[n2] = cov_f[n2, n2];
      cov_f_diag = diag_matrix(temp);
 
      f = multi_normal_rng(f_mu, cov_f_diag);

    }
    return f;
  }
///////////////////////////
// periodic + squared exponential prediction,
// for kernels 3 and 4 in the sum
  vector gp_pred_periodic_exp_quad_rng(real[] x2,
                     vector y, real[] x1,
                     matrix k,
                     real magnitude_1, real length_scale_1,
                     real magnitude_2, real length_scale_2, real period,
                     real sigma, real jitter) {                              
    // x2:               test data
    // x1:               training data
    // magnitude_1:      magnitude of squared exponential kernel
    // length_scale_1    length scale of squared exponential kernel
    // magnitude_2:        magnitude of periodic kernel
    // length_scale_2:   length_scale of periodic kernel
    // period:           perio of periodic kernel
    // sigma:         model noise
    // jitter:        for numerical stability for inverse, etc.

    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = k; // + diag_matrix(rep_vector(square(sigma), N1));
      matrix[N1, N1] L_K = cholesky_decompose(K);

      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_periodic_cov(x1, x2, magnitude_2, length_scale_2, period) .*
                               cov_exp_quad(x1, x2,  magnitude_1, length_scale_1);
      vector[N2] f_mu = (k_x1_x2' * K_div_y);

      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      matrix[N2, N2] cov_f =   gp_periodic_cov(x2, magnitude_2, length_scale_2, period) .*
                               cov_exp_quad(x2,  magnitude_1, length_scale_1) - v_pred' * v_pred   // K_t - (K_tn) ( K_n + I * sigma^2)^-1 K_nt) + sigma^2 I
                              + diag_matrix(rep_vector(jitter, N2));
      vector[N2] temp;
      matrix[N2, N2] cov_f_diag;
      for (n2 in 1:N2)
        temp[n2] = cov_f[n2, n2];
      cov_f_diag = diag_matrix(temp);
 
      f = multi_normal_rng(f_mu, cov_f_diag);

    }
    return f;
  }
///////////////////////////
  vector gp_pred_dot_prod_rng(real[] x2,
                     vector y, real[] x1,
                     matrix k,
                     real intercept, real sigma,                 // squared exp params + model noise
                     real jitter) {      
    // x2:            test data
    // x1:            training data
    // intercept:     intercept term in dot product kernel, sigma0 in GPML
    // sigma:         model noise
    // jitter:        for numerical stability for inverse, etc.

    int N1 = rows(y);
    int N2 = size(x2);
    vector[N2] f;
    {
      matrix[N1, N1] K = k;// + diag_matrix(rep_vector(square(sigma), N1));
      matrix[N1, N1] L_K = cholesky_decompose(K);

      vector[N1] L_K_div_y = mdivide_left_tri_low(L_K, y);
      vector[N1] K_div_y = mdivide_right_tri_low(L_K_div_y', L_K)';
      matrix[N1, N2] k_x1_x2 = gp_dot_prod_cov(x1, x2, intercept);
      vector[N2] f_mu = (k_x1_x2' * K_div_y);

      matrix[N1, N2] v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      matrix[N2, N2] cov_f =   gp_dot_prod_cov(x2, intercept) - v_pred' * v_pred
                              + diag_matrix(rep_vector(jitter, N2));
//      f = multi_normal_rng(f_mu, cov_f);
      vector[N2] temp;
      matrix[N2, N2] cov_f_diag;
      for (n2 in 1:N2)
        temp[n2] = cov_f[n2, n2];
      cov_f_diag = diag_matrix(temp);
 
      f = multi_normal_rng(f_mu, cov_f_diag);
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
  vector[M] I_ss[N];  // N x M matrix
  vector[M] I_ws[N];  // ""       ""
  real x_pred[N_pred];
}
transformed data {
  vector[N] mu = rep_vector(0, N);
}
////////////////////////////
parameters {
  //  f_1(t), squared exponential
  real<lower=1e-13, upper=400> length_scale_1;
  real<lower=1e-13> sigma_1;

 //   f_2(t), squared exponential
 real<lower=1e-13> length_scale_2;
 real<lower=1e-13> sigma_2; 

  //  f_3(t), weekly quasi-periodic
 real<lower=1e-13> length_scale_3_1;
 real<lower=1e-13> sigma_3_1;
 real<lower=1e-13> length_scale_3_2;

  //  f_4(t), yearly smooth seasonal
  real<lower=1e-13> length_scale_4_1;
  real<lower=1e-13> sigma_4_1;
  real<lower=1e-13> length_scale_4_2;

  //  f_5(t), indicators for weekends and special days
  real<lower=1e-13> sigma_5_1;
  real<lower=1e-13> sigma_5_2;

  // noise
  real<lower=1e-13> sigma;
}
transformed parameters {
  // TODO change this:
  matrix[N, N] k = cov_exp_quad(x, sigma_1, length_scale_1) +
                   cov_exp_quad(x, sigma_2, length_scale_2) + 
                   gp_periodic_cov(x, sigma_3_1, length_scale_3_1, 7) .*
                      cov_exp_quad(x, 1.0, length_scale_3_2) +
                   gp_periodic_cov(x, sigma_4_1, length_scale_4_1, 365.25) .*
                       cov_exp_quad(x, 1.0, length_scale_4_2) + 
                   gp_dot_prod_cov(I_ss, sigma_5_1) +
                   gp_dot_prod_cov(I_ws, sigma_5_2);
  real sq_sigma = square(sigma);
  for (n in 1:N)
    k[n, n] = k[n, n] + 1e-12;
}

model {
  matrix[N, N] L_k;
  L_k = cholesky_decompose(k);

  sigma ~ normal(0, 1);

  // smooth non-periodic component
  length_scale_1 ~ lognormal(log(365), 1);
  sigma_1 ~ normal(0, 1);
//  sigma_1 ~ normal(.7, 4);  // and also set inits as the MAP for this joint distribution?
  // making sigma priors more diffuse tends to help,
  // whereas making them more strict tends to make the model not initialize

  // faster changing non-periodic component
  length_scale_2 ~ lognormal(log(10), 1);
  sigma_2 ~ normal(0, 1);
//  sigma_2 ~ normal(.4, 4);

  // 7 day period
  length_scale_3_1 ~ lognormal(log(2), sqrt(2));
  sigma_3_1 ~ normal(0, 1); // ends up at 20 // decay??
  length_scale_3_2 ~ lognormal(log(20), 1);

  // 365.25 day period
  length_scale_4_1 ~ lognormal(log(100), sqrt(2));
  sigma_4_1 ~ normal(0, 1);
  length_scale_4_2 ~ lognormal(log(1000), sqrt(2));

  sigma_5_1 ~ normal(0, 1);
  sigma_5_2 ~ normal(0, 1);

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
  vector[N_pred] f5_1_pred;
  vector[N_pred] y5_1_pred;
  // f5_2 predictive
  vector[N_pred] f5_2_pred;
  vector[N_pred] y5_2_pred;
 

  // // f1 predictive
  // f1_pred = gp_pred_exp_quad_rng(x_pred, y, x, k, sigma_1, length_scale_1, sigma, 1e-6);

  // // f2 predictive
  // f2_pred = gp_pred_exp_quad_rng(x_pred, y, x, k, sigma_2, length_scale_2, sigma, 1e-6);

  // // f3 predictive
  // f3_pred = gp_pred_periodic_exp_quad_rng(x_pred, y, x, k,
  //                                         sigma_3_1, length_scale_3_1,
  //                                         1.0, length_scale_3_2, 7,
  //                                         sigma, 1e-6);
  // // f4 predictive
  // f4_pred = gp_pred_periodic_exp_quad_rng(x_pred, y, x, k,
  //                                         sigma_4_1, length_scale_4_1,
  //                                         1.0, length_scale_4_2, 365.25,
  //                                         sigma, 1e-6);
  // // f5_1 predictive
  // f5_1_pred = gp_pred_dot_prod_rng(x_pred, y, x, k, sigma_5_1, sigma, 1e-6);

  // // f5_2 predictive
  // f5_2_pred = gp_pred_dot_prod_rng(x_pred, y, x, k, sigma_5_2, sigma, 1e-6);


  for (n in 1:N_pred)
  {
//     y1_pred[n] = normal_rng(f1_pred[n], sigma);
//     y2_pred[n] = normal_rng(f2_pred[n], sigma);
 //    y3_pred[n] = normal_rng(f3_pred[n], sigma);
     // y4_pred[n] = normal_rng(f3_pred[n], sigma);
     // y5_1_pred[n] = normal_rng(f5_1_pred[n], sigma);
     // y5_2_pred[n] = normal_rng(f5_2_pred[n], sigma);
   }
}