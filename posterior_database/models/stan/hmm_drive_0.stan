// drive model (exponential dist)
data {
  int<lower=1> K;               // number of states (1 = none, 2 = drive)
  int<lower=1> N;               // length of process
  real u[N];                    // 1/speed
  real v[N];                    // hoop distance
  matrix<lower=0>[K,K] alpha;   // transit prior
}
parameters {
  simplex[K] theta1;
  simplex[K] theta2;
  // enforce an ordering: phi[1] <= phi[2]
  positive_ordered[K] phi;      // emission parameter for 1/speed
  positive_ordered[K] lambda;   // emission parameter for hoop dist
}
transformed parameters {
	simplex[K] theta[K];          // transit probs
	theta[1] = theta1;
	theta[2] = theta2;
}
model {
  // priors
  for (k in 1:K)
    target += dirichlet_lpdf(theta[k] | alpha[k,]');
  target+= normal_lpdf(phi[1] | 0, 1);
  target+= normal_lpdf(phi[2] | 3, 1);
  target+= normal_lpdf(lambda[1] | 0, 1);
  target+= normal_lpdf(lambda[2] | 3, 1);
  // forward algorithm
  {
    real acc[K];
    real gamma[N,K];
    for (k in 1:K)
      gamma[1,k] = exponential_lpdf(u[1] | phi[k]) + exponential_lpdf(v[1] | lambda[k]);
    for (t in 2:N) {
      for (k in 1:K) {
        for (j in 1:K)
          acc[j] = gamma[t-1,j] + log(theta[j,k]) + exponential_lpdf(u[t] | phi[k]) + exponential_lpdf(v[t] | lambda[k]);
        gamma[t,k] = log_sum_exp(acc);
      }
    }
    target+= log_sum_exp(gamma[N]);
  }
}

generated quantities {
  int<lower=1,upper=K> z_star[N];
  real log_p_z_star;
  // Viterbi algorithm
  {
    int back_ptr[N,K];
    real best_logp[N,K];
    for (k in 1:K)
      best_logp[1,K] = exponential_lpdf(u[1] | phi[k]) + exponential_lpdf(v[1] | lambda[k]);
    for (t in 2:N) {
      for (k in 1:K) {
        best_logp[t,k] = negative_infinity();
        for (j in 1:K) {
          real logp;
          logp = best_logp[t-1,j] + log(theta[j,k]) + exponential_lpdf(u[t] | phi[k]) + exponential_lpdf(v[t] | lambda[k]);
          if (logp > best_logp[t,k]) {
            back_ptr[t,k] = j;
            best_logp[t,k] = logp;
          }
        }
      }
    }
    log_p_z_star = max(best_logp[N]);
    for (k in 1:K)
      if (best_logp[N,k] == log_p_z_star)
        z_star[N] = k;
    for (t in 1:(N - 1))
      z_star[N - t] = back_ptr[N - t + 1, z_star[N - t + 1]];
  }
}
