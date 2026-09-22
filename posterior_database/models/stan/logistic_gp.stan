functions {
  vector gp_pred_rng(vector[] x_pred,
                     vector y1, vector[] x,
                     real magnitude, real[] length_scale,
                     real sig) {
    int N = rows(y1);
    int N_pred = size(x_pred);
    vector[N_pred] f2;
    {
      matrix[N, N] K = gp_matern52_cov(x, magnitude, length_scale);
      matrix[N, N] L_K = cholesky_decompose(K);
      vector[N] L_K_div_y1 = mdivide_left_tri_low(L_K, y1);
      vector[N] K_div_y1 = mdivide_right_tri_low(L_K_div_y1', L_K)';
      matrix[N, N_pred] k_x_x_pred = gp_matern52_cov(x, x_pred, magnitude, length_scale);
      f2 = (k_x_x_pred' * K_div_y1);
    }
    return f2;
  }
}
data {
  int<lower=1> N;
  int<lower=1> D;
  vector[D] x[N];
  int<lower=0,upper=1> y[N];

  int<lower=1> N_pred;
  vector[D] x_pred[N_pred];
}
parameters {
  real<lower=0> magnitude;
  real<lower=0> length_scale;
    real<lower=0> sig;
  vector[N] eta;
}
transformed parameters {
  vector[N] f;
  {
    matrix[N, N] K;
    matrix[N, N] L_K;   
    K = gp_matern52_cov(x, magnitude, length_scale);
    K = add_diag(K, 1e-12);
    L_K = cholesky_decompose(K);
    f = L_K * eta;
  }
}
model {
  magnitude ~ // what should the mangitude prior be?
  length_scale ~ // what should the length scale prior be?

  sig ~ normal(0, 2);
  
  eta ~ normal(0, 1);

  y ~ bernoulli_logit(f);
}
generated quantities {
  vector[N_pred] f_pred = gp_pred_rng(x_pred, f, x, magnitude, length_scale, sig);
  int y_pred[N_pred];
  int y_pred_in[N];
  
  for (n in 1:N) y_pred_in[n] = bernoulli_logit_rng(f[n]); // in sample prediction
  for (n in 1:N_pred) y_pred[n] = bernoulli_logit_rng(f_pred[n]); // out of sample predictions
}
