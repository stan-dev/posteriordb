functions {
  /* Function to compute the matrix square root */
  matrix sqrtm(matrix A) {
    int m = rows(A);
    vector[m] root_root_evals = sqrt(sqrt(eigenvalues_sym(A)));
    matrix[m, m] evecs = eigenvectors_sym(A);
    matrix[m, m] eprod = diag_post_multiply(evecs, root_root_evals);
    return tcrossprod(eprod);
  }
  /* Function to compute Kronecker product */
  matrix kronecker_prod(matrix A, matrix B) {
    matrix[rows(A) * rows(B), cols(A) * cols(B)] C;
    int m = rows(A);
    int n = cols(A);
    int p = rows(B);
    int q = cols(B);
    for (i in 1 : m) {
      for (j in 1 : n) {
        int row_start = (i - 1) * p + 1;
        int row_end = (i - 1) * p + p;
        int col_start = (j - 1) * q + 1;
        int col_end = (j - 1) * q + q;
        C[row_start : row_end, col_start : col_end] = A[i, j] * B;
      }
    }
    return C;
  }
  /* Function to transform A to P (inverse of part 2 of reparameterisation) */
  matrix AtoP(matrix A) {
    int m = rows(A);
    matrix[m, m] B = tcrossprod(A);
    for (i in 1 : m)
      B[i, i] += 1.0;
    return mdivide_left_spd(sqrtm(B), A);
  }
  /* Function to perform the reverse mapping from the Appendix. The details of
     how to perform Step 1 are in Section S1.3 of the Supplementary Materials.
     Returned: a length-p array of (m x m) matrices; the i-th component
               of the array is phi_i */
  array[] matrix rev_mapping(array[] matrix P, matrix Sigma) {
    int p = size(P);
    int m = rows(Sigma);
    array[p, p] matrix[m, m] phi_for;
    array[p, p] matrix[m, m] phi_rev;
    array[p + 1] matrix[m, m] Sigma_for;
    array[p + 1] matrix[m, m] Sigma_rev;
    matrix[m, m] S_for;
    matrix[m, m] S_rev;
    array[p + 1] matrix[m, m] S_for_list;
    // Step 1:
    Sigma_for[p + 1] = Sigma;
    S_for_list[p + 1] = sqrtm(Sigma);
    for (s in 1 : p) {
      // In this block of code S_rev is B^{-1} and S_for is a working matrix
      S_for = -tcrossprod(P[p - s + 1]);
      for (i in 1 : m)
        S_for[i, i] += 1.0;
      S_rev = sqrtm(S_for);
      S_for_list[p - s + 1] = mdivide_right_spd(mdivide_left_spd(S_rev,
                                                                 sqrtm(
                                                                 quad_form_sym(
                                                                 Sigma_for[
                                                                 p - s + 2],
                                                                 S_rev))),
                                                S_rev);
      Sigma_for[p - s + 1] = tcrossprod(S_for_list[p - s + 1]);
    }
    // Step 2:
    Sigma_rev[1] = Sigma_for[1];
    for (s in 0 : (p - 1)) {
      S_for = S_for_list[s + 1];
      S_rev = sqrtm(Sigma_rev[s + 1]);
      phi_for[s + 1, s + 1] = mdivide_right_spd(S_for * P[s + 1], S_rev);
      phi_rev[s + 1, s + 1] = mdivide_right_spd(S_rev * P[s + 1]', S_for);
      if (s >= 1) {
        for (k in 1 : s) {
          phi_for[s + 1, k] = phi_for[s, k]
                              - phi_for[s + 1, s + 1] * phi_rev[s, s - k + 1];
          phi_rev[s + 1, k] = phi_rev[s, k]
                              - phi_rev[s + 1, s + 1] * phi_for[s, s - k + 1];
        }
      }
      Sigma_rev[s + 2] = Sigma_rev[s + 1]
                         - quad_form_sym(Sigma_for[s + 1],
                                         phi_rev[s + 1, s + 1]');
    }
    return phi_for[p];
  }
  /* Function to compute the joint (stationary) distribution of
     (y_0, ..., y_{1-p}, eps_0, ..., eps_{1-q}). Details of the underpinning
     ideas are given in Section S7 of the Supplementary Materials. */
  matrix initial_joint_var(matrix Sigma, array[] matrix phi,
                           array[] matrix theta) {
    int p = size(phi);
    int q = size(theta);
    int m = rows(Sigma);
    matrix[(p + q) * m, (p + q) * m] companion_mat = rep_matrix(0.0,
                                                                (p + q) * m,
                                                                (p + q) * m);
    matrix[(p + q) * m, (p + q) * m] companion_var = rep_matrix(0.0,
                                                                (p + q) * m,
                                                                (p + q) * m);
    matrix[(p + q) * m * (p + q) * m, (p + q) * m * (p + q) * m] tmp = diag_matrix(rep_vector(
                                                                    1.0,
                                                                    (
                                                                    p + q)
                                                                    * m
                                                                    * (
                                                                    p + q)
                                                                    * m));
    matrix[(p + q) * m, (p + q) * m] Omega;
    // Construct phi_tilde:
    for (i in 1 : p) {
      companion_mat[1 : m, ((i - 1) * m + 1) : (i * m)] = phi[i];
      if (i > 1) {
        for (j in 1 : m) {
          companion_mat[(i - 1) * m + j, (i - 2) * m + j] = 1.0;
        }
      }
    }
    for (i in 1 : q) {
      companion_mat[1 : m, ((p + i - 1) * m + 1) : ((p + i) * m)] = theta[i];
    }
    if (q > 1) {
      for (i in 2 : q) {
        for (j in 1 : m) {
          companion_mat[(p + i - 1) * m + j, (p + i - 2) * m + j] = 1.0;
        }
      }
    }
    // Construct Sigma_tilde:
    companion_var[1 : m, 1 : m] = Sigma;
    companion_var[(p * m + 1) : ((p + 1) * m), (p * m + 1) : ((p + 1) * m)] = Sigma;
    companion_var[1 : m, (p * m + 1) : ((p + 1) * m)] = Sigma;
    companion_var[(p * m + 1) : ((p + 1) * m), 1 : m] = Sigma;
    // Compute Gamma0_tilde
    tmp -= kronecker_prod(companion_mat, companion_mat);
    Omega = to_matrix(tmp \ to_vector(companion_var), (p + q) * m,
                      (p + q) * m);
    // Ensure Omega is symmetric:
    for (i in 1 : (rows(Omega) - 1)) {
      for (j in (i + 1) : rows(Omega)) {
        Omega[j, i] = Omega[i, j];
      }
    }
    return Omega;
  }
}
data {
  int<lower=1> m; // Dimension of observation vector
  int<lower=1> p; // Order of VAR component
  int<lower=1> q; // Order of VMA component
  int<lower=1> N; // Length of time series
  array[N] vector[m] y; // Time series
  // Hyperparameters in exchangeable prior for the A_i (component 1 of arrays)
  // and D_i (component 2 of arrays). See Section 3.2 of the paper.
  array[2] vector[2] es;
  array[2] vector<lower=0>[2] fs;
  array[2] vector<lower=0>[2] gs;
  array[2] vector<lower=0>[2] hs;
  // Hyperparameters in exchangeable inverse Wishart prior for Sigma
  real<lower=0> scale_diag; // Diagonal element in scale matrix
  real<lower=-scale_diag / (m - 1)> scale_offdiag; /* Off-diagonal element in scale
                                                      matrix */
  real<lower=m + 3> df; /* Degrees of freedom (limit ensures
                           finite variance) */
}
transformed data {
  vector[m] mu = rep_vector(0.0, m); // (Zero)-mean of VARMA process
  matrix[m, m] scale_mat; // Scale-matrix in prior for Sigma
  for (i in 1 : m) {
    for (j in 1 : m) {
      if (i == j)
        scale_mat[i, j] = scale_diag;
      else
        scale_mat[i, j] = scale_offdiag;
    }
  }
}
parameters {
  vector[m * (p + q)] init; // (y_0^T, ..., y_{1-p}^T, eps_0^T, ..., eps_{1-q}^T)^T
  array[p] matrix[m, m] A; // The A_i
  array[q] matrix[m, m] D; // The D_i
  cov_matrix[m] Sigma; // Error variance, Sigma
  // Means and precisions in top-level prior for the diagonal and off-diagonal
  // elements in the A_i
  array[2] vector[p] Amu;
  array[2] vector<lower=0>[p] Aomega;
  // Means and precisions in top-level prior for the diagonal and off-diagonal
  // elements in the D_i
  array[2] vector[q] Dmu;
  array[2] vector<lower=0>[q] Domega;
}
transformed parameters {
  array[p] matrix[m, m] phi; // The phi_i
  array[q] matrix[m, m] theta; // The theta_i
  cov_matrix[(p + q) * m] Omega; // Variance in initial distribution, i.e. Gamma0_tilde
  array[N + p] vector[m] yfull; // (y_{1-p}^T, ..., y_{N}^T)^T
  array[q] vector[m] epsinit; // (eps_0^T, ..., eps_{1-q}^T)^T
  {
    array[p] matrix[m, m] P;
    array[q] matrix[m, m] R;
    for (i in 1 : p)
      P[i] = AtoP(A[i]);
    for (i in 1 : q)
      R[i] = AtoP(D[i]);
    phi = rev_mapping(P, Sigma);
    theta = rev_mapping(R, Sigma);
    for (i in 1 : q)
      theta[i] = -theta[i];
    Omega = initial_joint_var(Sigma, phi, theta);
    for (i in 1 : p) {
      yfull[i] = init[((p - i) * m + 1) : ((p - i + 1) * m)]; // y[1-p],...,y[0]
    }
    yfull[(p + 1) : (p + N)] = y;
    for (i in 1 : q) {
      epsinit[i] = init[(p * m + (i - 1) * m + 1) : (p * m + i * m)]; // eps[0],...,eps[1-q]
    }
  }
}
model {
  vector[(p + q) * m] mut_init; /* Marginal mean of
                                   (y_0, ..., y_{1-p}, eps_0, ..., eps_{1-q}) */
  array[N] vector[m] mut; // Conditional means of y_{1}, ..., y_{N}
  // (Complete data) likelihood:
  for (t in 1 : p)
    mut_init[((t - 1) * m + 1) : (t * m)] = mu;
  mut_init[(p * m + 1) : ((p + q) * m)] = rep_vector(0.0, q * m);
  mut[1] = mu;
  for (i in 1 : p) {
    mut[1] += phi[i] * (yfull[p + 1 - i] - mu);
  }
  for (i in 1 : q) {
    mut[1] += theta[i] * epsinit[i];
  }
  if (q > 1) {
    for (t in 2 : q) {
      mut[t] = mu;
      for (i in 1 : p) {
        mut[t] += phi[i] * (yfull[p + t - i] - mu);
      }
      for (i in 1 : (t - 1)) {
        mut[t] += theta[i] * (yfull[p + t - i] - mut[t - i]);
      }
      for (i in t : q) {
        mut[t] += theta[i] * epsinit[i - t + 1];
      }
    }
  }
  for (t in (q + 1) : N) {
    mut[t] = mu;
    for (i in 1 : p) {
      mut[t] += phi[i] * (yfull[p + t - i] - mu);
    }
    for (i in 1 : q) {
      mut[t] += theta[i] * (yfull[p + t - i] - mut[t - i]);
    }
  }
  init ~ multi_normal(mut_init, Omega);
  y ~ multi_normal(mut, Sigma);
  // Prior:
  Sigma ~ inv_wishart(df, scale_mat);
  for (s in 1 : p) {
    diagonal(A[s]) ~ normal(Amu[1, s], 1 / sqrt(Aomega[1, s]));
    for (i in 1 : m) {
      for (j in 1 : m) {
        if (i != j)
          A[s, i, j] ~ normal(Amu[2, s], 1 / sqrt(Aomega[2, s]));
      }
    }
  }
  for (s in 1 : q) {
    diagonal(D[s]) ~ normal(Dmu[1, s], 1 / sqrt(Domega[1, s]));
    for (i in 1 : m) {
      for (j in 1 : m) {
        if (i != j)
          D[s, i, j] ~ normal(Dmu[2, s], 1 / sqrt(Domega[2, s]));
      }
    }
  }
  // Hyperprior:
  for (i in 1 : 2) {
    Amu[i] ~ normal(es[1, i], fs[1, i]);
    Aomega[i] ~ gamma(gs[1, i], hs[1, i]);
    Dmu[i] ~ normal(es[2, i], fs[2, i]);
    Domega[i] ~ gamma(gs[2, i], hs[2, i]);
  }
}
generated quantities {
  matrix[m, m * p] topblock;
  for (lag in 1 : p) {
    topblock[ : , ((lag - 1) * m + 1) : (lag * m)] = phi[lag];
  }
  matrix[m * p, m * p] companion = rep_matrix(0.0, m * p, m * p);
  companion[1 : m,  : ] = topblock;
  if (p > 1) {
    companion[(m + 1) : (m * p), 1 : (m * (p - 1))] = diag_matrix(
                                                                  rep_vector
                                                                  (1.0,
                                                                   m
                                                                   * (
                                                                   p - 1)));
  }
  complex_vector[m * p] lambdas = eigenvalues(companion);
  vector[m * p] lambda_moduli = abs(lambdas);
  real max_lambda_modulus = max(lambda_moduli);
}
