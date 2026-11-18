// Linear Gaussian toy version of the plasma model, non-centred parameterization.
// Langmore et al. (2022), arXiv:2103.07515, eqs. (1), (15) and Fig. 4.
//
//   Z ~ N(0, I),  x = L_pr Z,  y ~ N(A x, sigma^2 I)
//   C_pr[i, j] = exp(-(s_i - s_j)^2 / (2 tau^2)) + delta * 1{i = j}
//
// This is the "prior reparameterization" of sec. 4.2. The posterior is exactly
// Gaussian; plasma_linear_reference.json holds its analytic mean and sd.

data {
  int<lower=1> N;                // unknowns
  int<lower=1> M;                // measurements
  vector[N] s;                   // grid locations of the unknowns
  matrix[M, N] A;                // forward matrix
  vector[M] y;                   // measurements
  real<lower=0> sigma;           // noise sd
  real<lower=0> tau;             // prior correlation length
  real<lower=0> delta;           // shrinkage on the diagonal
}

transformed data {
  matrix[N, N] L_pr;
  {
    matrix[N, N] C;
    for (i in 1:N)
      for (j in 1:N)
        C[i, j] = exp(-square(s[i] - s[j]) / (2 * square(tau)));
    L_pr = cholesky_decompose(add_diag(C, delta));
  }
}

parameters {
  vector[N] Z;
}

transformed parameters {
  vector[N] x = L_pr * Z;
}

model {
  target += std_normal_lpdf(Z);
  target += normal_lpdf(y | A * x, sigma);
}
