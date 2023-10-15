// source: https://github.com/luisdamiano/stancon18/blob/master/stan/hmm_gaussian.stan

functions {
  vector normalize(vector x) {
    return x / sum(x);
  }
}
data {
  int<lower=1> T; // number of observations (length)
  int<lower=1> K; // number of hidden states
  array[T] real y; // observations
}
parameters {
  // Discrete state model
  simplex[K] pi1; // initial state probabilities
  array[K] simplex[K] A; // transition probabilities
  // A[i][j] = p(z_t = j | z_{t-1} = i)
  
  // Continuous observation model
  ordered[K] mu; // observation means
  array[K] real<lower=0> sigma; // observation standard deviations
}
transformed parameters {
  array[T] vector[K] logalpha;
  
  {
    // Forward algorithm log p(z_t = j | x_{1:t})
    array[K] real accumulator;
    
    logalpha[1] = log(pi1) + normal_lpdf(y[1] | mu, sigma);
    
    for (t in 2 : T) {
      for (j in 1 : K) {
        // j = current (t)
        for (i in 1 : K) {
          // i = previous (t-1)
          // Murphy (2012) Eq. 17.48
          // belief state      + transition prob + local evidence at t
          accumulator[i] = logalpha[t - 1, i] + log(A[i, j])
                           + normal_lpdf(y[t] | mu[j], sigma[j]);
        }
        logalpha[t, j] = log_sum_exp(accumulator);
      }
    }
  } // Forward
}
model {
  target += log_sum_exp(logalpha[T]); // Note: update based only on last logalpha
}
generated quantities {
  array[T] vector[K] logbeta;
  array[T] vector[K] loggamma;
  
  array[T] vector[K] alpha;
  array[T] vector[K] beta;
  array[T] vector[K] gamma;
  
  array[T] int<lower=1, upper=K> zstar;
  real logp_zstar;
  
  {
    // Forward algortihm
    for (t in 1 : T) {
      alpha[t] = softmax(logalpha[t]);
    }
  } // Forward
  
  {
    // Backward algorithm log p(x_{t+1:T} | z_t = j)
    array[K] real accumulator;
    
    for (j in 1 : K) {
      logbeta[T, j] = 1;
    }
    
    for (tforward in 0 : (T - 2)) {
      int t;
      t = T - tforward;
      
      for (j in 1 : K) {
        // j = previous (t-1)
        for (i in 1 : K) {
          // i = next (t)
          // Murphy (2012) Eq. 17.58
          // backwards t    + transition prob + local evidence at t
          accumulator[i] = logbeta[t, i] + log(A[j, i])
                           + normal_lpdf(y[t] | mu[i], sigma[i]);
        }
        logbeta[t - 1, j] = log_sum_exp(accumulator);
      }
    }
    
    for (t in 1 : T) {
      beta[t] = softmax(logbeta[t]);
    }
  } // Backward
  
  {
    // Forwards-backwards algorithm log p(z_t = j | x_{1:T})
    for (t in 1 : T) {
      loggamma[t] = alpha[t] .* beta[t];
    }
    
    for (t in 1 : T) {
      gamma[t] = normalize(loggamma[t]);
    }
  } // Forwards-backwards
  
  {
    // Viterbi algorithm
    array[T, K] int bpointer; // backpointer to the most likely previous state on the most probable path
    array[T, K] real delta; // max prob for the seq up to t
    // with final output from state k for time t
    
    for (j in 1 : K) {
      delta[1, K] = normal_lpdf(y[1] | mu[j], sigma[j]);
    }
    
    for (t in 2 : T) {
      for (j in 1 : K) {
        // j = current (t)
        delta[t, j] = negative_infinity();
        for (i in 1 : K) {
          // i = previous (t-1)
          real logp;
          logp = delta[t - 1, i] + log(A[i, j])
                 + normal_lpdf(y[t] | mu[j], sigma[j]);
          if (logp > delta[t, j]) {
            bpointer[t, j] = i;
            delta[t, j] = logp;
          }
        }
      }
    }
    
    logp_zstar = max(delta[T]);
    
    for (j in 1 : K) {
      if (delta[T, j] == logp_zstar) {
        zstar[T] = j;
      }
    }
    
    for (t in 1 : (T - 1)) {
      zstar[T - t] = bpointer[T - t + 1, zstar[T - t + 1]];
    }
  }
}


