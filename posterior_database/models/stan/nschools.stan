data {
  int<lower=1> n; // number of schools
  int<lower=1> num_states;
  int<lower=1> num_districts_per_state;
  int<lower=1> num_types;
  real Y[n];
  real<lower=0> sigma[n];
  int<lower=1, upper=num_states> state_idx[n];
  int<lower=1, upper=num_districts_per_state> district_idx[n];
  int<lower=1, upper=num_types> type_idx[n];
  real<lower=0> dof_baseline;
  real<lower=0> scale_baseline;
  real<lower=0> scale_state;
  real<lower=0> scale_district;
  real<lower=0> scale_type;
}

transformed data {
}

parameters {
  real<lower=0> sigma_state;
  real<lower=0> sigma_district;
  real<lower=0> sigma_type;
  real beta_baseline;
  vector[num_states] beta_state;
  matrix[num_states, num_districts_per_state] beta_district;
  vector[num_types] beta_type;
}
transformed parameters {
    vector[n] Yhat;
    #vector[n] z;
    for (i in 1:n) {
        Yhat[i] = beta_baseline
                + beta_state[state_idx[i]]
                + beta_district[state_idx[i], district_idx[i]]
                + beta_type[type_idx[i]];
    };
    #z = (to_vector(Y)-Yhat);
}
model {
  sigma_state ~ cauchy(0, scale_state);
  sigma_district ~ cauchy(0, scale_district);
  sigma_type ~ cauchy(0, scale_type);
  beta_baseline ~ student_t(dof_baseline, 0, scale_baseline);
  beta_state ~ normal(0, sigma_state);
  to_vector(beta_district) ~ normal(0, sigma_district);
  beta_type ~ normal(0, sigma_type);
  #for (i in 1:n){
  #  z[i] ~ normal(0, sigma[i]);
  #};
  //z ~ normal(0, sigma);
  //Y = Yhat + z * sigma;
  Y ~ normal(Yhat, sigma);
}
generated quantities{
}
