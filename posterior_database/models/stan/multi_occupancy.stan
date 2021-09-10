functions {
  matrix cov_matrix_2d(vector sigma, real rho) {
    matrix[2,2] Sigma;
    Sigma[1,1] = square(sigma[1]);
    Sigma[2,2] = square(sigma[2]);
    Sigma[1,2] = sigma[1] * sigma[2] * rho;
    Sigma[2,1] = Sigma[1,2];
    return Sigma;
  }

  real lp_observed(int X, int K, real logit_psi, real logit_theta) {
    return log_inv_logit(logit_psi)
      + binomial_logit_lpmf(X | K, logit_theta);
  }

  real lp_unobserved(int K, real logit_psi, real logit_theta) {
    return log_sum_exp(lp_observed(0, K, logit_psi, logit_theta),
                       log1m_inv_logit(logit_psi));
  }

  real lp_never_observed(int J, int K, real logit_psi, real logit_theta,
                         real Omega) {
      real lp_unavailable = bernoulli_lpmf(0 | Omega);
      real lp_available = bernoulli_lpmf(1 | Omega)
        + J * lp_unobserved(K, logit_psi, logit_theta);
      return log_sum_exp(lp_unavailable, lp_available);
    }
}
data {
  int<lower=1> J;  // sites within region
  int<lower=1> K;  // visits to sites
  int<lower=1> n;  // observed species
  int<lower=0, upper=K> X[n,J];  // visits when species i was detected at site j
  int<lower=n> S;  // superpopulation size
}
parameters {
  real alpha;  //  site-level occupancy
  real beta;   //  site-level detection
  real<lower=0, upper=1> Omega;  // availability of species

  real<lower=-1,upper=1> rho_uv;  // correlation of (occupancy, detection)
  vector<lower=0>[2] sigma_uv;    // sd of (occupancy, detection)
  vector[S] uv1;
  vector[S] uv2;
}
transformed parameters {
	vector[2] uv[S];        // species-level (occupancy, detection)
  vector[S] logit_psi;    // log odds  of occurrence
  vector[S] logit_theta;  // log odds of detection
  for (i in 1:S) {
	  uv[i,1] = uv1[i];
  	uv[i,2] = uv2[i];
    logit_psi[i] = uv[i,1] + alpha;
  }
  for (i in 1:S)
    logit_theta[i] = uv[i,2] + beta;
}
model {
  // priors
  alpha ~ cauchy(0, 2.5);
  beta ~ cauchy(0, 2.5);
  sigma_uv ~ cauchy(0, 2.5);
  (rho_uv + 1) / 2 ~ beta(2, 2);
  // Parse warnings: uv ~ multi_normal(rep_vector(0, 2), cov_matrix_2d(sigma_uv, rho_uv));
  target += multi_normal_lpdf(uv | rep_vector(0, 2), cov_matrix_2d(sigma_uv, rho_uv));
  Omega ~ beta(2,2);

  // likelihood
  for (i in 1:n) {
    1 ~ bernoulli(Omega); // observed, so available
    for (j in 1:J) {
      if (X[i,j] > 0)
        target += lp_observed(X[i,j], K, logit_psi[i], logit_theta[i]);
      else
        target += lp_unobserved(K, logit_psi[i], logit_theta[i]);
    }
  }
  for (i in (n + 1):S)
    target += lp_never_observed(J, K, logit_psi[i], logit_theta[i], Omega);
}
generated quantities {
  real<lower=0,upper=S> E_N = S * Omega; // model-based expectation species
  int<lower=0,upper=S> E_N_2;  // posterior simulated species
  vector[2] sim_uv;
  real logit_psi_sim;
  real logit_theta_sim;

  E_N_2 = n;
  for (i in (n+1):S) {
    real lp_unavailable = bernoulli_lpmf(0 | Omega);
    real lp_available = bernoulli_lpmf(1 | Omega)
      + J * lp_unobserved(K, logit_psi[i], logit_theta[i]);
    real Pr_available = exp(lp_available
                            - log_sum_exp(lp_unavailable, lp_available));
    E_N_2 = E_N_2 + bernoulli_rng(Pr_available);
  }

  sim_uv = multi_normal_rng(rep_vector(0,2),
                             cov_matrix_2d(sigma_uv, rho_uv));
  logit_psi_sim = alpha + sim_uv[1];
  logit_theta_sim = beta + sim_uv[2];
}
