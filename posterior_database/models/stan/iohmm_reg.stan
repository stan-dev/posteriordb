// source: https://github.com/luisdamiano/stancon18/blob/master/stan/iohmm_reg.stan

functions {
  vector normalize(vector x) {
    return x / sum(x);
  }
}
data {
  int<lower=1> T; // number of observations (length)
  int<lower=1> K; // number of hidden states
  
  int<lower=1> M; // size of the input vector
  array[T] real y; // output (scalar)
  array[T] vector[M] u; // input (vector)
}
parameters {
  // Discrete state model
  simplex[K] pi1; // initial state probabilities
  array[K] vector[M] w; // state regressors
  
  // Continuous observation model
  array[K] vector[M] b; // mean regressors
  array[K] real<lower=0> sigma; // residual standard deviations
}
transformed parameters {
  array[T] vector[K] logalpha;
  
  array[T] vector[K] unA;
  array[T] vector[K] A;
  array[T] vector[K] logA;
  
  array[T] vector[K] logoblik;
  
  {
    // Transition probability matrix p(z_t = j | z_{t-1} = i, u)
    unA[1] = pi1; // Filler
    A[1] = pi1; // Filler x2
    logA[1] = log(A[1]); // Filler x3
    
    for (t in 2 : T) {
      for (j in 1 : K) {
        // j = current (t)
        unA[t][j] = u[t]' * w[j];
      }
      A[t] = softmax(unA[t]);
      logA[t] = log(A[t]);
    }
  }
  
  {
    // Observation likelihood
    for (t in 1 : T) {
      for (j in 1 : K) {
        logoblik[t][j] = normal_lpdf(y[t] | u[t]' * b[j], sigma[j]);
      }
    }
  }
  
  {
    // Forward algorithm log p(z_t = j | x_{1:t})
    array[K] real accumulator;
    
    for (j in 1 : K) {
      logalpha[1][j] = log(pi1[j]) + logoblik[1][j];
    }
    
    for (t in 2 : T) {
      for (j in 1 : K) {
        // j = current (t)
        for (i in 1 : K) {
          // i = previous (t-1)
          // Murphy (2012) Eq. 17.48
          // belief state + transition prob + local evidence at t
          accumulator[i] = logalpha[t - 1, i] + logA[t][i] + logoblik[t][j];
        }
        logalpha[t, j] = log_sum_exp(accumulator);
      }
    }
  } // Forward
}
model {
  for (j in 1 : K) {
    w[j] ~ normal(0, 5);
    b[j] ~ normal(0, 5);
    sigma[j] ~ normal(0, 3);
  }
  
  target += log_sum_exp(logalpha[T]); // Note: update based only on last logalpha
}
generated quantities {
  array[T] vector[K] logbeta;
  array[T] vector[K] loggamma;
  
  array[T] vector[K] alpha;
  array[T] vector[K] beta;
  array[T] vector[K] gamma;
  
  array[T] vector[K] hatpi;
  array[T] int<lower=1, upper=K> hatz;
  array[T] real haty;
  
  array[T] int<lower=1, upper=K> zstar;
  real logp_zstar;
  
  {
    // Forward algorithm log p(z_t = j | x_{1:t})
    for (t in 1 : T) {
      alpha[t] = softmax(logalpha[t]);
    }
  } // Forward
  
  {
    // Backward algorithm log p(x_{t+1:T} | z_t = j)
    array[K] real accumulator;
    int tbackwards;
    
    for (j in 1 : K) {
      logbeta[T, j] = 1;
    }
    
    for (tforwards in 0 : (T - 2)) {
      tbackwards = T - tforwards;
      
      for (j in 1 : K) {
        // j = previous (t-1)
        for (i in 1 : K) {
          // i = next (t)
          // Murphy (2012) Eq. 17.58
          // backwards t  + transition prob + local evidence at t
          accumulator[i] = logbeta[tbackwards, i] + logA[tbackwards][i]
                           + logoblik[tbackwards][i];
        }
        logbeta[tbackwards - 1, j] = log_sum_exp(accumulator);
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
    // Fitted state
    array[T] vector[K] reg;
    for (t in 1 : T) {
      for (j in 1 : K) {
        reg[t, j] = u[t]' * to_vector(w[j]);
      }
      hatpi[t] = softmax(reg[t]);
      hatz[t] = categorical_rng(hatpi[t]);
    }
  }
  
  {
    // Fitted output
    array[T] real reg;
    for (t in 1 : T) {
      reg[t] = u[t]' * b[hatz[t]];
      haty[t] = normal_rng(reg[t], sigma[hatz[t]]);
    }
  }
  
  {
    // Viterbi decoding
    array[T, K] int bpointer; // backpointer to the source of the link
    array[T, K] real delta; // max prob for the seq up to t
    // with final output from state k for time t
    
    for (j in 1 : K) {
      delta[1, K] = logoblik[1][j];
    }
    
    for (t in 2 : T) {
      for (j in 1 : K) {
        delta[t, j] = negative_infinity();
        for (i in 1 : K) {
          real logp;
          logp = delta[t - 1, i] + logA[t][i] + logoblik[t][j];
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


