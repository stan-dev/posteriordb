functions {
  real growth_factor_weibull(real t, real omega, real theta) {
    return 1 - exp(-(t / theta) ^ omega);
  }
  
  real growth_factor_loglogistic(real t, real omega, real theta) {
    real pow_t_omega = t ^ omega;
    return pow_t_omega / (pow_t_omega + theta ^ omega);
  }
}
data {
  int<lower=0, upper=1> growthmodel_id;
  
  int n_data;
  int n_time;
  int n_cohort;
  
  array[n_data] int cohort_id;
  array[n_data] int t_idx;
  
  array[n_cohort] int cohort_maxtime;
  
  vector<lower=0>[n_time] t_value;
  
  vector[n_cohort] premium;
  vector[n_data] loss;
}
parameters {
  real<lower=0> omega;
  real<lower=0> theta;
  
  vector<lower=0>[n_cohort] LR;
  
  real mu_LR;
  real<lower=0> sd_LR;
  
  real<lower=0> loss_sd;
}
transformed parameters {
  vector[n_time] gf;
  vector[n_data] lm;
  
  for (i in 1 : n_time) {
    gf[i] = growthmodel_id == 1
            ? growth_factor_weibull(t_value[i], omega, theta)
            : growth_factor_loglogistic(t_value[i], omega, theta);
  }
  
  for (i in 1 : n_data) {
    lm[i] = LR[cohort_id[i]] * premium[cohort_id[i]] * gf[t_idx[i]];
  }
}
model {
  mu_LR ~ normal(0, 0.5);
  sd_LR ~ lognormal(0, 0.5);
  
  LR ~ lognormal(mu_LR, sd_LR);
  
  loss_sd ~ lognormal(0, 0.7);
  
  omega ~ lognormal(0, 0.5);
  theta ~ lognormal(0, 0.5);
  
  loss ~ normal(lm, (loss_sd * premium)[cohort_id]);
}
generated quantities {
  array[n_cohort] vector<lower=0>[n_time] loss_sample;
  array[n_cohort] vector<lower=0>[n_time] loss_prediction;
  array[n_cohort] vector<lower=0>[n_time] step_ratio;
  
  real mu_LR_exp;
  
  real<lower=0> ppc_minLR;
  real<lower=0> ppc_maxLR;
  real<lower=0> ppc_EFC;
  
  for (i in 1 : n_cohort) {
    step_ratio[i] = rep_vector(1, n_time);
    loss_sample[i] = LR[i] * premium[i] * gf;
  }
  
  mu_LR_exp = exp(mu_LR);
  
  for (i in 1 : n_data) {
    loss_prediction[cohort_id[i], t_idx[i]] = loss[i];
  }
  
  for (i in 1 : n_cohort) {
    for (j in 2 : n_time) {
      step_ratio[i, j] = gf[t_idx[j]] / gf[t_idx[j - 1]];
    }
  }
  
  for (i in 1 : n_cohort) {
    for (j in (cohort_maxtime[i] + 1) : n_time) {
      loss_prediction[i, j] = loss_prediction[i, j - 1] * step_ratio[i, j];
    }
  }
  
  // Create PPC distributions for the max/min of LR
  ppc_minLR = min(LR);
  ppc_maxLR = max(LR);
  
  // Create total reserve PPC
  ppc_EFC = 0;
  
  for (i in 1 : n_cohort) {
    ppc_EFC = ppc_EFC + loss_prediction[i, n_time]
              - loss_prediction[i, cohort_maxtime[i]];
  }
}


