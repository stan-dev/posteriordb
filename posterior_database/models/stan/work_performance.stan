data {
  int<lower=1> N;
  int<lower=1> J;

  array[N] int<lower=1, upper=J> participant;

  vector[N] performance;
  vector[N] time;
  vector[N] self_control;

  vector[N] gender;
  vector[N] age;
  vector[N] children;
  vector[N] income;
  vector[N] education;
  vector[N] share_wfh;

  vector[N] extraversion;
  vector[N] agreeableness;
  vector[N] conscientiousness;
  vector[N] neuroticism;
  vector[N] openness;
}

parameters {

  real alpha;

  real beta_time;
  real beta_self_control;
  real beta_interaction;

  real beta_gender;
  real beta_age;
  real beta_children;
  real beta_income;
  real beta_education;
  real beta_share_wfh;

  real beta_extraversion;
  real beta_agreeableness;
  real beta_conscientiousness;
  real beta_neuroticism;
  real beta_openness;

  real<lower=0> sigma;

  vector<lower=0>[2] sigma_b;

  cholesky_factor_corr[2] L_Omega;

  matrix[J, 2] z_b;
}

transformed parameters {

  matrix[J, 2] b;

  b =
    (diag_pre_multiply(
      sigma_b,
      L_Omega
    ) * z_b')';
}

model {

  // Priors

  alpha ~ normal(0, 1);

  beta_time ~ normal(0, 1);
  beta_self_control ~ normal(0, 1);
  beta_interaction ~ normal(0, 1);

  beta_gender ~ normal(0, 1);
  beta_age ~ normal(0, 1);
  beta_children ~ normal(0, 1);
  beta_income ~ normal(0, 1);
  beta_education ~ normal(0, 1);
  beta_share_wfh ~ normal(0, 1);

  beta_extraversion ~ normal(0, 1);
  beta_agreeableness ~ normal(0, 1);
  beta_conscientiousness ~ normal(0, 1);
  beta_neuroticism ~ normal(0, 1);
  beta_openness ~ normal(0, 1);

  sigma ~ normal(0, 1);

  sigma_b ~ normal(0, 1);

  L_Omega ~ lkj_corr_cholesky(2);

  to_vector(z_b) ~ normal(0, 1);


  // Likelihood

  for (n in 1:N) {

    real mu;

    mu =
        alpha
        + b[participant[n], 1]
        + beta_time * time[n]
        + b[participant[n], 2] * time[n]
        + beta_self_control * self_control[n]
        + beta_interaction
          * time[n]
          * self_control[n]
        + beta_gender * gender[n]
        + beta_age * age[n]
        + beta_children * children[n]
        + beta_income * income[n]
        + beta_education * education[n]
        + beta_share_wfh * share_wfh[n]
        + beta_extraversion * extraversion[n]
        + beta_agreeableness * agreeableness[n]
        + beta_conscientiousness * conscientiousness[n]
        + beta_neuroticism * neuroticism[n]
        + beta_openness * openness[n];

    performance[n] ~ normal(mu, sigma);
  }
}

generated quantities {
  corr_matrix[2] Omega;
  vector[N] performance_rep;

  Omega = multiply_lower_tri_self_transpose(L_Omega);

  for (n in 1:N) {
    real mu;

    mu =
        alpha
        + b[participant[n], 1]
        + beta_time * time[n]
        + b[participant[n], 2] * time[n]
        + beta_self_control * self_control[n]
        + beta_interaction * time[n] * self_control[n]
        + beta_gender * gender[n]
        + beta_age * age[n]
        + beta_children * children[n]
        + beta_income * income[n]
        + beta_education * education[n]
        + beta_share_wfh * share_wfh[n]
        + beta_extraversion * extraversion[n]
        + beta_agreeableness * agreeableness[n]
        + beta_conscientiousness * conscientiousness[n]
        + beta_neuroticism * neuroticism[n]
        + beta_openness * openness[n];

    performance_rep[n] = normal_rng(mu, sigma);
  }
}
