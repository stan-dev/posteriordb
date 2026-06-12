data {
    int<lower=1>T; //number of days
    vector<lower=0>[T-1] y; //index values of sp500
}

transformed data {
    vector[T-1] log_returns;
    for (i in 1:(T-1)) {
        log_returns[i] = log(y[i+1]) - log(y[i]);
  }
}

parameters {
    real<lower=0> nu;            // degrees of freedom of Student-t
    vector<lower=0>[T-1] s;        // scale parameters at each day
}

model {
    // Prior on nu: Exponential(100)  =>  log p(nu) = -0.01 * nu + const
    target += -0.01 * nu;

    // Prior on s[1]: Exponential(100)  =>  log p(s[1]) = -0.01 * s[1] + const 
    target += -0.01 * s[1];

    // Likelihood: (log y_i - log y_{i-1}) / s_i ~ t_nu
    // Add -log(s_i) for each term because of the Jacobian of standardization.
    for (i in 1:(T-1)) {
        target += student_t_lpdf(log_returns[i] | nu, 0, s[i]);
        }
   
    {
        real sum_sq = 0;
        for (i in 2:T-1) {
            sum_sq += square(log(s[i]) - log(s[i-1]));
        }
    target += -((T + 1) / 2.0) * log(0.01 + 0.5 * sum_sq);
    }
}