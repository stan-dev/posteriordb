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
 
//      f = multi_normal_rng(f_mu, cov_f_diag);
      f = f_mu;
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
 
//      f = multi_normal_rng(f_mu, cov_f_diag);
      f = f_mu;
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
  real<lower=1e-13> length_scale_1;
  real<lower=1e-13> magnitude_1;

  // kernel 2, periodic component
  real<lower=1e-13> length_scale_2_1;
  real<lower=1e-13> magnitude_2;
  real<lower=1e-13> length_scale_2_2;

  // student t priors
  real<lower=0> stud_t_sigma;
  real<lower=0> stud_t_nu;

  // model noise
  real<lower=1e-13> sigma;
  vector[N] eta;
}
transformed parameters {
  vector[N] f;
  matrix[N, N] L_K;
  matrix[N, N] K = cov_exp_quad(xn, magnitude_1, length_scale_1) +
                  gp_periodic_cov(xn, magnitude_2, length_scale_2_1, 7.0) .*
                  cov_exp_quad(xn, 1.0, length_scale_2_2);

  real sq_sigma = square(sigma);
  for (n in 1:N) {
    K[n, n] = K[n, n] + sq_sigma;
  }
  L_K = cholesky_decompose(K);
  f = L_K * eta;
}
model {
  // kernel 1 priors
  length_scale_1 ~ lognormal(log(10), log(2)); // may be second parameter is wrong??
  magnitude_1 ~ lognormal(log(1), log(2));

  // kernel 2 priors
  length_scale_2_1 ~ lognormal(log(2), log(2));
  magnitude_2 ~ lognormal(log(.5), log(2));
  length_scale_2_2 ~ lognormal(log(20), log(2));

  // student_t likelihood priors
  // stud_t_sigma ~ lognormal(log(.05), log(2));
  // stud_t_nu ~ lo

  eta ~ normal(0, 1);

  target += student_t_lpdf(yn | stud_t_nu, mu, stud_t_sigma);
}
generated quantities {
  // f1 predictive        
  vector[N] f1_pred;
  vector[N] y1_pred;
  // f2 predictive
  vector[N] f2_pred;
  vector[N] y2_pred;

  // f1_predictive
  f1_pred = gp_pred_exp_quad_rng(xn, yn, xn, K, magnitude_1, length_scale_1, sigma, 1e-6);

  // f2 predictive
  f2_pred = gp_pred_periodic_exp_quad_rng(xn, yn, xn, K,
                                          magnitude_2, length_scale_2_1,
                                          1.0, length_scale_2_2, 7,
                                          sigma, 1e-6);
}