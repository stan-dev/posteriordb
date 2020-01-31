// generated with brms 2.10.0
functions {
}
data {
  int<lower=1> N;  // number of observations
  vector[N] Y;  // response variable
  // data for splines
  int Ks;  // number of linear effects
  matrix[N, Ks] Xs;  // design matrix for the linear effects
  // data for spline s(times,k=40)
  int nb_1;  // number of bases
  int knots_1[nb_1];  // number of knots
  // basis function matrices
  matrix[N, knots_1[1]] Zs_1_1;
  // data for splines
  int Ks_sigma;  // number of linear effects
  matrix[N, Ks_sigma] Xs_sigma;  // design matrix for the linear effects
  // data for spline s(times,k=40)
  int nb_sigma_1;  // number of bases
  int knots_sigma_1[nb_sigma_1];  // number of knots
  // basis function matrices
  matrix[N, knots_sigma_1[1]] Zs_sigma_1_1;
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
}
parameters {
  // temporary intercept for centered predictors
  real Intercept;
  // spline coefficients
  vector[Ks] bs;
  // parameters for spline s(times,k=40)
  // standarized spline coefficients
  vector[knots_1[1]] zs_1_1;
  // standard deviations of the coefficients
  real<lower=0> sds_1_1;
  // temporary intercept for centered predictors
  real Intercept_sigma;
  // spline coefficients
  vector[Ks_sigma] bs_sigma;
  // parameters for spline s(times,k=40)
  // standarized spline coefficients
  vector[knots_sigma_1[1]] zs_sigma_1_1;
  // standard deviations of the coefficients
  real<lower=0> sds_sigma_1_1;
}
transformed parameters {
  // actual spline coefficients
  vector[knots_1[1]] s_1_1 = sds_1_1 * zs_1_1;
  // actual spline coefficients
  vector[knots_sigma_1[1]] s_sigma_1_1 = sds_sigma_1_1 * zs_sigma_1_1;
}
model {
  // initialize linear predictor term
  vector[N] mu = Intercept + rep_vector(0, N) + Xs * bs + Zs_1_1 * s_1_1;
  // initialize linear predictor term
  vector[N] sigma = Intercept_sigma + rep_vector(0, N) + Xs_sigma * bs_sigma + Zs_sigma_1_1 * s_sigma_1_1;
  for (n in 1:N) {
    // apply the inverse link function
    sigma[n] = exp(sigma[n]);
  }
  // priors including all constants
  target += student_t_lpdf(Intercept | 3, -13, 36);
  target += normal_lpdf(zs_1_1 | 0, 1);
  target += student_t_lpdf(sds_1_1 | 3, 0, 36)
    - 1 * student_t_lccdf(0 | 3, 0, 36);
  target += student_t_lpdf(Intercept_sigma | 3, 0, 10);
  target += normal_lpdf(zs_sigma_1_1 | 0, 1);
  target += student_t_lpdf(sds_sigma_1_1 | 3, 0, 36)
    - 1 * student_t_lccdf(0 | 3, 0, 36);
  // likelihood including all constants
  if (!prior_only) {
    target += normal_lpdf(Y | mu, sigma);
  }
}
generated quantities {
  // actual population-level intercept
  real b_Intercept = Intercept;
  // actual population-level intercept
  real b_sigma_Intercept = Intercept_sigma;
}

