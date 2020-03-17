// generated with brms 2.10.0
functions {

  /* compute a latent Gaussian process
   * Args:
   *   x: array of continuous predictor values
   *   sdgp: marginal SD parameter
   *   lscale: length-scale parameter
   *   zgp: vector of independent standard normal variables 
   * Returns:  
   *   a vector to be added to the linear predictor
   */ 
  vector gp(vector[] x, real sdgp, vector lscale, vector zgp) { 
    int Dls = rows(lscale);
    int N = size(x);
    matrix[N, N] cov;
    if (Dls == 1) {
      // one dimensional or isotropic GP
      cov = cov_exp_quad(x, sdgp, lscale[1]);
    } else {
      // multi-dimensional non-isotropic GP
      cov = cov_exp_quad(x[, 1], sdgp, lscale[1]);
      for (d in 2:Dls) {
        cov = cov .* cov_exp_quad(x[, d], 1, lscale[d]);
      }
    }
    for (n in 1:N) {
      // deal with numerical non-positive-definiteness
      cov[n, n] += 1e-12;
    }
    return cholesky_decompose(cov) * zgp;
  }

  /* Spectral density function of a Gaussian process
   * Args:
   *   x: array of numeric values of dimension NB x D
   *   sdgp: marginal SD parameter
   *   lscale: vector of length-scale parameters
   * Returns: 
   *   numeric values of the function evaluated at 'x'
   */
  vector spd_cov_exp_quad(vector[] x, real sdgp, vector lscale) {
    int NB = dims(x)[1];
    int D = dims(x)[2];
    int Dls = rows(lscale);
    vector[NB] out;
    if (Dls == 1) {
      // one dimensional or isotropic GP
      real constant = square(sdgp) * (sqrt(2 * pi()) * lscale[1])^D;
      real neg_half_lscale2 = -0.5 * square(lscale[1]);
      for (m in 1:NB) {
        out[m] = constant * exp(neg_half_lscale2 * dot_self(x[m]));
      }
    } else {
      // multi-dimensional non-isotropic GP
      real constant = square(sdgp) * sqrt(2 * pi())^D * prod(lscale);
      vector[Dls] neg_half_lscale2 = -0.5 * square(lscale);
      for (m in 1:NB) {
        out[m] = constant * exp(dot_product(neg_half_lscale2, square(x[m])));
      }
    }
    return out;
  }
  /* compute an approximate latent Gaussian process
   * Args:
   *   X: Matrix of Laplacian eigen functions at the covariate values
   *   sdgp: marginal SD parameter
   *   lscale: vector of length-scale parameters
   *   zgp: vector of independent standard normal variables 
   *   slambda: square root of the Laplacian eigen values
   * Returns:  
   *   a vector to be added to the linear predictor
   */ 
  vector gpa(matrix X, real sdgp, vector lscale, vector zgp, vector[] slambda) { 
    vector[cols(X)] diag_spd = sqrt(spd_cov_exp_quad(slambda, sdgp, lscale));
    return X * (diag_spd .* zgp);
  }
}
data {
  int<lower=1> N;  // number of observations
  vector[N] Y;  // response variable
  // data related to GPs
  // number of sub-GPs (equal to 1 unless 'by' was used)
  int<lower=1> Kgp_1;
  int<lower=1> Dgp_1;  // GP dimension
  // number of basis functions of an approximate GP
  int<lower=1> NBgp_1;
  // approximate GP basis matrices
  matrix[N, NBgp_1] Xgp_1;
  // approximate GP eigenvalues
  vector[Dgp_1] slambda_1[NBgp_1];
  // data related to GPs
  // number of sub-GPs (equal to 1 unless 'by' was used)
  int<lower=1> Kgp_sigma_1;
  int<lower=1> Dgp_sigma_1;  // GP dimension
  // number of basis functions of an approximate GP
  int<lower=1> NBgp_sigma_1;
  // approximate GP basis matrices
  matrix[N, NBgp_sigma_1] Xgp_sigma_1;
  // approximate GP eigenvalues
  vector[Dgp_sigma_1] slambda_sigma_1[NBgp_sigma_1];
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
}
parameters {
  // temporary intercept for centered predictors
  real Intercept;
  // GP standard deviation parameters
  vector<lower=0>[Kgp_1] sdgp_1;
  // GP length-scale parameters
  vector<lower=0>[1] lscale_1[Kgp_1];
  // latent variables of the GP
  vector[NBgp_1] zgp_1;
  // temporary intercept for centered predictors
  real Intercept_sigma;
  // GP standard deviation parameters
  vector<lower=0>[Kgp_sigma_1] sdgp_sigma_1;
  // GP length-scale parameters
  vector<lower=0>[1] lscale_sigma_1[Kgp_sigma_1];
  // latent variables of the GP
  vector[NBgp_sigma_1] zgp_sigma_1;
}
transformed parameters {
}
model {
  // initialize linear predictor term
  vector[N] mu = Intercept + rep_vector(0, N) + gpa(Xgp_1, sdgp_1[1], lscale_1[1], zgp_1, slambda_1);
  // initialize linear predictor term
  vector[N] sigma = Intercept_sigma + rep_vector(0, N) + gpa(Xgp_sigma_1, sdgp_sigma_1[1], lscale_sigma_1[1], zgp_sigma_1, slambda_sigma_1);
  for (n in 1:N) {
    // apply the inverse link function
    sigma[n] = exp(sigma[n]);
  }
  // priors including all constants
  target += student_t_lpdf(Intercept | 3, -13, 36);
  target += student_t_lpdf(sdgp_1 | 3, 0, 36)
    - 1 * student_t_lccdf(0 | 3, 0, 36);
  target += normal_lpdf(zgp_1 | 0, 1);
  target += inv_gamma_lpdf(lscale_1[1] | 1.124909, 0.0177);
  target += student_t_lpdf(Intercept_sigma | 3, 0, 10);
  target += student_t_lpdf(sdgp_sigma_1 | 3, 0, 36)
    - 1 * student_t_lccdf(0 | 3, 0, 36);
  target += normal_lpdf(zgp_sigma_1 | 0, 1);
  target += inv_gamma_lpdf(lscale_sigma_1[1] | 1.124909, 0.0177);
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

