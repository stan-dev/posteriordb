data {
  // Dynamic component
  int<lower=0> nParties;                               // no. parties
  int<lower=0> nInst;                                  // no. polling institutes
  int<lower=0> nPolls;                                 // no. published polls
  int<lower=0> nPeriods;                               // no. days (last day = Election Day)
  array[nPolls] int<lower=0, upper=nInst> iid;         // institute id of each poll
  array[nPolls] int<lower=0, upper=nPeriods> date;     // day each poll was published
  array[nPolls, nParties] int<lower=0> y;              // poll results as counts

  // Structural component
  int<lower=0> LA;                                     // no. elections in structural data
  int<lower=0> L;                                      // LA + 1
  int<lower=0> Nobs;                                   // no. observed party-election results
  int<lower=0> Nmis;                                   // no. unknown results (upcoming election)
  int<lower=0> N;                                      // total no. party-election rows
  array[N] int<lower=0> election;                      // election id of each row
  int<lower=0> K;                                      // no. predictors
  vector[Nobs] v_obs;                                  // observed vote shares
  matrix[N, K] x;                                      // predictors, all rows
  matrix[Nmis, K] xE;                                  // predictors, upcoming election

  // Auxiliary
  array[Nobs] int<lower=1, upper=Nobs + Nmis> ii_obs;  // index of observed rows
  array[Nmis] int<lower=1, upper=Nobs + Nmis> ii_mis;  // index of unknown rows
  array[LA] int s;                                     // no. parties per election
  matrix[L, K] b_prior;                                // pre-trained coefficients
  vector[L] b0_prior;                                  // pre-trained intercepts
}

parameters {
  // Structural component
  simplex[Nmis] v_mis;                                 // unknown results inside the regression
  simplex[nParties] vE;                                // fundamentals forecast (anchor)
  vector[L] b0_raw;                                    // standardised intercepts
  matrix[L, K] b_raw;                                  // standardised coefficients
  real drift_b0;
  array[K] real drift;
  real<lower=0> sigma_b0;
  array[K] real<lower=0> sigma_b;

  // Dynamic component
  cholesky_factor_corr[nParties - 1] S_cor;            // Cholesky factor of evolution correlation
  vector<lower=0>[nParties - 1] sigma_evo;             // daily volatility per log-ratio
  matrix[nPeriods - 1, nParties - 1] z;                // standardised daily innovations
  vector[(nInst - 1) * (nParties - 1)] h_z;            // standardised house effects

  // Forecast shock (historical poll error)
  cholesky_factor_corr[nParties - 1] S_shock_cor;
  vector<lower=0>[nParties - 1] sigma_shock;
  vector[nParties - 1] shock_z;
}

transformed parameters {
  // Structural component
  array[L] real mu_b0;
  matrix[L, K] mu_b;
  vector[L] b0;
  matrix[L, K] b;
  vector[N] v;
  vector[N] a;
  vector[nParties] a_pred;

  // Dynamic component
  matrix[nInst - 1, nParties - 1] house_effect_raw;
  matrix[nInst, nParties] house_effect;
  matrix[nPeriods - 1, nParties - 1] alphastar;        // latent states
  matrix[nPeriods, nParties] alphastar_prior;          // states and house effects on poll days
  vector[nParties - 1] alphastarforecast;              // Election Day state incl. shock
  vector[nParties] alphastarforecast_prior;            // same, with reference party's 0

  // --- Coefficient trend
  mu_b0[1] = 0;
  for (k in 1:K) mu_b[1, k] = 0;
  for (j in 2:L) mu_b0[j] = b0_prior[j - 1] + drift_b0;
  for (k in 1:K)
    for (j in 2:L)
      mu_b[j, k] = b_prior[j - 1, k] + drift[k];

  // --- Non-centred coefficients
  // b0[1] ~ normal(b0_prior[1], 10), b0[j] ~ normal(mu_b0[j], sigma_b0), same for b
  b0[1] = b0_prior[1] + 10 * b0_raw[1];
  for (j in 2:L) b0[j] = mu_b0[j] + sigma_b0 * b0_raw[j];
  for (k in 1:K) {
    b[1, k] = b_prior[1, k] + 10 * b_raw[1, k];
    for (j in 2:L) b[j, k] = mu_b[j, k] + sigma_b[k] * b_raw[j, k];
  }

  // --- Dirichlet regression parameters
  v[ii_obs] = v_obs;
  v[ii_mis] = v_mis;
  for (i in 1:N)
    a[i] = exp(b0[election[i]] + b[election[i], ] * x[i, ]');
  for (j in 1:nParties)
    a_pred[j] = exp(b0[L] + b[L, ] * xE[j, ]');

  // --- House effects: sum to zero across institutes and across parties
  // house_effect_raw ~ normal(0, 0.001)
  house_effect_raw = 0.001 * to_matrix(h_z, nInst - 1, nParties - 1);
  house_effect[2:nInst, 2:nParties] = house_effect_raw;
  for (j in 2:nParties)
    house_effect[1, j] = -sum(house_effect[2:nInst, j]);
  for (c in 1:nInst)
    house_effect[c, 1] = -sum(house_effect[c, 2:nParties]);

  // --- Backward random walk, non-centred
  {
    matrix[nParties - 1, nParties - 1] L_evo = diag_pre_multiply(sigma_evo, S_cor);
    // Sum of house effects of all polls on each day
    matrix[nPeriods, nParties] he_day = rep_matrix(0, nPeriods, nParties);
    for (k in 1:nPolls)
      he_day[date[k]] += house_effect[iid[k]];

    // Election Day: anchor = alr(vE), plus house effects of any polls that day
    for (j in 1:nParties)
      alphastar_prior[nPeriods, j] = log(vE[j]) - log(vE[nParties]);
    alphastar_prior[nPeriods] += he_day[nPeriods];

    // Days nPeriods-1, ..., 1. Each state equals the next day's (shifted) state
    // plus one step: alphastar[t] ~ multi_normal(alphastar_prior[t+1], W).
    for (i in 1:(nPeriods - 1)) {
      int t = nPeriods - i;
      alphastar[t] = alphastar_prior[t + 1, 1:(nParties - 1)] + (L_evo * z[t]')';
      alphastar_prior[t, 1:(nParties - 1)] = alphastar[t];
      alphastar_prior[t, nParties] = 0;                          // reference party
      alphastar_prior[t] += he_day[t];
    }
  }

  // --- Forecast shock, non-centred
  // alphastarforecast ~ multi_normal(alphastar_prior[nPeriods, 1:(nParties-1)], shock covariance)
  alphastarforecast = alphastar_prior[nPeriods, 1:(nParties - 1)]'
                      + diag_pre_multiply(sigma_shock, S_shock_cor) * shock_z;
  alphastarforecast_prior[1:(nParties - 1)] = alphastarforecast;
  alphastarforecast_prior[nParties] = 0;
}

model {
  int pos = 1;

  // Structural priors
  b0_raw ~ std_normal();
  to_vector(b_raw) ~ std_normal();
  drift_b0 ~ normal(0, 10);
  drift ~ normal(0, 10);
  sigma_b0 ~ normal(0, 1);
  sigma_b ~ normal(0, 1);

  // Structural likelihood: one Dirichlet per election
  for (l in 1:LA) {
    segment(v, pos, s[l]) ~ dirichlet(segment(a, pos, s[l]));
    pos = pos + s[l];
  }

  // Fundamentals forecast -> Election Day anchor
  vE ~ dirichlet(a_pred);

  // Dynamic priors
  sigma_evo ~ normal(0, 0.1);
  S_cor ~ lkj_corr_cholesky(50);
  to_vector(z) ~ std_normal();                        // backward random walk
  h_z ~ std_normal();                                 // house effects

  // Forecast shock priors
  sigma_shock ~ normal(0, 0.18);
  S_shock_cor ~ lkj_corr_cholesky(100);
  shock_z ~ std_normal();

  // Polls
  for (k in 1:nPolls)
    y[k] ~ multinomial_logit(alphastar_prior[date[k]]');
}

generated quantities {
  matrix[nPeriods, nParties] ea = exp(alphastar_prior);
  matrix[nPeriods, nParties] alpha;                    // daily vote shares
  vector[nParties] ef = exp(alphastarforecast_prior);
  vector[nParties] forecast = ef / sum(ef);            // final forecast
  matrix[nParties - 1, nParties - 1] Omega =           // evolution correlation matrix
    multiply_lower_tri_self_transpose(S_cor);

  for (t in 1:nPeriods)
    alpha[t] = ea[t] / sum(ea[t]);
}
