
data {
  // Data concerning matches is entered as a long df, with each row 
  // corresponding to a specific match between home and away teams.
  
  int<lower=1> M;                       // training matches
  int<lower=0> M_test;                  // test matches (season to predict)
  int<lower=2> nteams;                  // number of teams.
  int<lower=1> T;                       // number of seasons (train + test)
  int<lower=1> S;                       // number of bookmakers

  array[M] int<lower=1, upper=nteams> team1;   // home team
  array[M] int<lower=1, upper=nteams> team2;   // away team
  array[M] int<lower=1, upper=T> season; // index each match to a season
  array[M] int<lower=0> y1;             // home goals
  array[M] int<lower=0> y2;             // away goals

  // Test matches between home and away teams
  array[M_test] int<lower=1, upper=nteams> team1_test; 
  array[M_test] int<lower=1, upper=nteams> team2_test;
  
  // index each test-match to a season
  array[M_test] int<lower=1, upper=T> season_test; 

  // row = match, column = bookmaker
  // Training data used to fit the model represent seasons 2007/08-2015/16
  matrix<lower=0>[M, S] theta_bm1;      // expected goals for home team
  matrix<lower=0>[M, S] theta_bm2;      // expected goals for AWAY team
  // Test data, the data we predict on, season 2016/17
  matrix<lower=0>[M_test, S] theta_bm1_test; // expected goals for home TEAM
  matrix<lower=0>[M_test, S] theta_bm2_test; // expected goals for AWAY team

  // Average expected goals over the S bookmakers gives us one value per match
  // alpha1 for home matches and alpha2 for AWAY matches
  vector[M] alpha1; // home team training
  vector[M] alpha2; // AWAY team training
  vector[M_test] alpha1_test; // home test
  vector[M_test] alpha2_test; // AWAY test
}

parameters {
  real mu;                              // global intercept of amount of goals
  real home;                            // home advantage
  real<lower=0> sigma2_att;             // variance of attack effects, positive
  real<lower=0> sigma2_def;             // variance of defence effects, positive
  real mu_att;
  real mu_def;
  
  // matrices (teams = rows, columns = season) standardized changes in attack
  // and defense from season to season, used to build a random walk
  matrix[nteams, T] z_att;            
  matrix[nteams, T] z_def;
  

  // tau_1, tau_2 in eq. 3.7
  real<lower=0, upper=10> tau1;
  real<lower=0, upper=10> tau2;

  vector<lower=0, upper=1>[M] p;        // match-specific mixing weights

  // model estimates it from S bookmaker's values in eq 3.7
  // and averages it with historical theta using weight p in eq 3.3
  vector<lower=0>[M] lambda1; // home team, training matches
  vector<lower=0>[M] lambda2; // AWAY team, training matches
  vector<lower=0>[M_test] lambda1_test; // home team, test matches
  vector<lower=0>[M_test] lambda2_test; // AWAY team, test matches
}

transformed parameters {
  matrix[nteams, T] att;                // computed attacking and defending
  matrix[nteams, T] def;                // strengths in the matrices
  vector[M] theta1; // expected home goals based on historical data (team strengths)
  vector[M] theta2; // expected away goals based on historical data (team strengths)
  vector[M] rate1;  // expected home goals: mix of historical (theta) and bookmaker (lambda) rates
  vector[M] rate2;  // expected away goals: mix of historical (theta) and bookmaker (lambda) rates
  {
    // We write the random walk with the drift written non-centered:
    matrix[nteams, T] att_star; // attack strength before zero-sum centring
    matrix[nteams, T] def_star; // defence strength before zero-sum centring

    att_star[, 1] =  mu_att + sqrt(sigma2_att) * z_att[, 1];
    def_star[, 1] =  mu_def + sqrt(sigma2_def) * z_def[, 1];


    for (h in 2:T) {
      att_star[, h] = mu_att + att_star[, h - 1] + sqrt(sigma2_att) * z_att[, h];
      def_star[, h] = mu_def + def_star[, h - 1] + sqrt(sigma2_def) * z_def[, h];
    }
    for (h in 1:T) {
      att[, h] = att_star[, h] - mean(att_star[, h]);
      def[, h] = def_star[, h] - mean(def_star[, h]);
    }
  }
  // compute the expected number of goals for home and away team in match m for 
  // all matches based on historical data
  for (m in 1:M) {
    theta1[m] = exp(mu + home + att[team1[m], season[m]] + def[team2[m], season[m]]);
    theta2[m] = exp(mu       + att[team2[m], season[m]] + def[team1[m], season[m]]);
  }
  
  // likelihood for the number of goals scored require rate parameters
  // The rate is modeled as a mix between historical data (theta) and bookmakers
  // odds (lambda). The mixing parameter p uses a non-informative prior.
  // See eq. 3.3.
  rate1 = p .* theta1 + (1 - p) .* lambda1; // home team
  rate2 = p .* theta2 + (1 - p) .* lambda2; // away team
}

model {
// standard normal prior on the standardised changes: later scaled by sqrt(sigma2)
// in transformed parameters, this gives the random walk for team strengths
  to_vector(z_att) ~ std_normal();
  to_vector(z_def) ~ std_normal();

  // priors for mu and home
  mu     ~ normal(0, sqrt(10));              
  home   ~ normal(0, sqrt(10));
  mu_att ~ normal(0, sqrt(10));
  mu_def ~ normal(0, sqrt(10));
  // priors for sigma2 attack and defence
  sigma2_att ~ inv_gamma(0.001, 0.001); 
  sigma2_def ~ inv_gamma(0.001, 0.001);
  p ~ beta(1, 1);                       // p is drawn at random   

  // The priors for bookmakers
  lambda1 ~ lognormal(alpha1, sqrt(10)); // home team, training matches
  lambda2 ~ lognormal(alpha2, sqrt(10)); // away team, training matches
  lambda1_test ~ lognormal(alpha1_test, sqrt(10)); // home team, test matches
  lambda2_test ~ lognormal(alpha2_test, sqrt(10)); // away team, test matches

  // Bookmaker likelihood defined in eq 3.7
  // For each match for S bookmakers the implied scoring rates are
  // defined as lognormal with location lambda and spread tau
  for (s in 1:S) { // loop over the bookmakers
    theta_bm1[, s] ~ lognormal(lambda1, tau1); // home team, training
    theta_bm2[, s] ~ lognormal(lambda2, tau2); // away team, training
    if (M_test > 0) {
      theta_bm1_test[, s] ~ lognormal(lambda1_test, tau1); // home team, test
      theta_bm2_test[, s] ~ lognormal(lambda2_test, tau2); // away team, test
    }
  }

  // Using the rates modeled earlier, we have a mix between historical data
  // and bookmakers odds. Insert this into a poisson distribution for no.
  // of goals scored. Again, see eq.3.3
  y1 ~ poisson(rate1);
  y2 ~ poisson(rate2);
}

generated quantities {
  // We are interested in storing some quantities concerning predictions.
  
  // Predicted historical goal rates for the test matches
  vector[M_test] theta1_test; // home
  vector[M_test] theta2_test; // Away
  
  // Predicted no. goals for the test matches.
  array[M_test] int y1_test; // home 
  array[M_test] int y2_test; // away
  
  // These quantities are only used for the output. Possible to extract if we
  // wish to see them.
  array[M] int y1_rep; // The predicted goals, home
  array[M] int y2_rep; // The predicted goals, away
  vector[M] log_lik; // log likelihood

  
  for (m in 1:M_test) {
    // p is simply chosen at random
    real p_new = beta_rng(1, 1);
    
    // We compute thetas as a function of one teams attack that match,
    // and the others defense. Note also the inclusion of hometeam advantage,
    // and a baseline rate of scoring goals mu.
    real th1 = exp(mu + home + att[team1_test[m], season_test[m]] // home
                            + def[team2_test[m], season_test[m]]);
             
    // Same as for the hometeam, but without advantage.         
    real th2 = exp(mu + att[team2_test[m], season_test[m]] // away
                     + def[team1_test[m], season_test[m]]);
                     
    // Compute the rates for the number of goals y                 
    theta1_test[m] = p_new * th1 + (1 - p_new) * lambda1_test[m];
    theta2_test[m] = p_new * th2 + (1 - p_new) * lambda2_test[m];
   
    // Insert the final rates and draw a value y.
    y1_test[m] = poisson_rng(theta1_test[m]);
    y2_test[m] = poisson_rng(theta2_test[m]);
  }
  for (m in 1:M) { // filling the empty output measurements.
    y1_rep[m] = poisson_rng(rate1[m]); // The predicted goals, home
    y2_rep[m] = poisson_rng(rate2[m]); // The predicted goals, away
    
    // log likelihood
    log_lik[m] = poisson_lpmf(y1[m] | rate1[m]) + poisson_lpmf(y2[m] | rate2[m]);
  }
}



