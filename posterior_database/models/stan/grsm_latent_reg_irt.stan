functions {
  real rsm(int y, real theta, real beta, vector kappa) {
    vector[rows(kappa) + 1] unsummed;
    vector[rows(kappa) + 1] probs;
    unsummed = append_row(rep_vector(0, 1), theta - beta - kappa);
    probs = softmax(cumulative_sum(unsummed));
    return categorical_lpmf(y + 1 | probs);
  }
  matrix obtain_adjustments(matrix W) {
    real min_w;
    real max_w;
    int minmax_count;
    matrix[2, cols(W)] adj;
    adj[1, 1] = 0;
    adj[2, 1] = 1;
    if (cols(W) > 1) {
      for (k in 2 : cols(W)) {
        // remaining columns
        min_w = min(W[1 : rows(W), k]);
        max_w = max(W[1 : rows(W), k]);
        minmax_count = 0;
        for (j in 1 : rows(W)) {
          minmax_count = minmax_count + W[j, k] == min_w || W[j, k] == max_w;
        }
        if (minmax_count == rows(W)) {
          // if column takes only 2 values
          adj[1, k] = mean(W[1 : rows(W), k]);
          adj[2, k] = max_w - min_w;
        } else {
          // if column takes > 2 values
          adj[1, k] = mean(W[1 : rows(W), k]);
          adj[2, k] = sd(W[1 : rows(W), k]) * 2;
        }
      }
    }
    return adj;
  }
}
data {
  int<lower=1> I; // # items
  int<lower=1> J; // # persons
  int<lower=1> N; // # responses
  array[N] int<lower=1, upper=I> ii; // i for n
  array[N] int<lower=1, upper=J> jj; // j for n
  array[N] int<lower=0> y; // response for n; y in {0 ... m_i}
  int<lower=1> K; // # person covariates
  matrix[J, K] W; // person covariate matrix
}
transformed data {
  int m; // # steps
  matrix[2, K] adj; // values for centering and scaling covariates
  matrix[J, K] W_adj; // centered and scaled covariates
  m = max(y);
  adj = obtain_adjustments(W);
  for (k in 1 : K) {
    for (j in 1 : J) {
      W_adj[j, k] = (W[j, k] - adj[1, k]) / adj[2, k];
    }
  }
}
parameters {
  vector<lower=0>[I] alpha;
  vector[I - 1] beta_free;
  vector[m - 1] kappa_free;
  vector[J] theta;
  vector[K] lambda_adj;
}
transformed parameters {
  vector[I] beta;
  vector[m] kappa;
  beta = append_row(beta_free, rep_vector(-1 * sum(beta_free), 1));
  kappa = append_row(kappa_free, rep_vector(-1 * sum(kappa_free), 1));
}
model {
  alpha ~ lognormal(1, 1);
  target += normal_lpdf(beta | 0, 3);
  target += normal_lpdf(kappa | 0, 3);
  theta ~ normal(W_adj * lambda_adj, 1);
  lambda_adj ~ student_t(3, 0, 1);
  for (n in 1 : N) {
    target += rsm(y[n], theta[jj[n]] .* alpha[ii[n]], beta[ii[n]], kappa);
  }
}
generated quantities {
  // This part is currently not working
  //  vector[K] lambda;
  //  lambda[2 : K] = lambda_adj[2 : K] ./ to_vector(adj[2, 2 : K]);
  //  lambda[1] = W_adj[1, 1 : K] * lambda_adj[1 : K]
  //              - W[1, 2 : K] * lambda[2 : K];
}


