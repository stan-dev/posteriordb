functions {
 // return (A \otimes B) v where:
 // A is n1 x n1, B = n2 x n2, V = n2 x n1 = reshape(v,n2,n1)
 matrix kron_mvprod(matrix A, matrix B, matrix V) {
   return transpose(A * transpose(B * V));
 }
 // A is a length n1 vector, B is a length n2 vector.
 // Treating them as diagonal matrices, this calculates:
 // v = (A \otimes B + sigma2)ˆ{-1}
 // and returns the n1 x n2 matrix V = reshape(v,n1,n2)
 matrix calculate_eigenvalues(vector A, vector B, int n1, int n2, real sigma2) {
   matrix[n1,n2] e;
   for(i in 1:n1) {
    for(j in 1:n2) {
      e[i,j] = (A[i] * B[j] + sigma2);
   } }
   return(e);
 }
}
data {
 int<lower=1> n1;
 int<lower=1> n2; // categories for learning cross-type correlations
 vector[n2] x1; // observation locations (e.g. timestamps)
 matrix[n2,n1] y; // NB: this should be reshape(y, n2, n1),
}
transformed data {
 matrix[n1, n1] xd;

// where y corresponds to expand.grid(x2,x1). // To double-check, make sure that y[i,j] is // the observation from category x2[i]
// at location x1[j]
 for (i in 1:n1) {
   xd[i, i] = 0;
   for (j in (i+1):n1) {
    xd[i, j] = -((x1[i]-x1[j]) ^ 2);
    xd[j, i] = xd[i, j];
   }
  }
}
parameters {
 real<lower=0> var1; // signal variance
 real<lower=0> bw1; // this is equivalent to 1/sqrt(length-scale)

 cholesky_factor_corr[n2] L;
 real<lower=0.00001> sigma1;
}

transformed parameters {
 matrix[n1, n1] Sigma1;
 matrix[n1, n1] Q1;
 vector[n1] R1;
 matrix[n2, n2] Q2;
 vector[n2] R2;
 matrix<lower=0>[n2,n1] eigenvalues;
 matrix[n2, n2] Lambda = multiply_lower_tri_self_transpose(L);

 Sigma1 = var1 * exp(xd * bw1);

 for(i in 1:n1)
   Sigma1[i,i] = Sigma1[i,i] + .00001;

 Q1 = eigenvectors_sym(Sigma1);
 R1 = eigenvalues_sym(Sigma1);
 Q2 = eigenvectors_sym(Lambda);
 R2 = eigenvalues_sym(Lambda);
 eigenvalues = calculate_eigenvalues(R2,R1,n2,n1,sigma1);
}

model {
 var1 ~ lognormal(0,1);
 bw1 ~ cauchy(0,2.5);
 sigma1 ~ lognormal(0,1);
 L ~ lkj_corr_cholesky(2);

  target +=
   -0.5 * sum(y .* kron_mvprod(Q1,Q2, // calculates -0.5 * y’ (K1 \otimes K2) y
          kron_mvprod(transpose(Q1),transpose(Q2),y) ./ eigenvalues))
     -0.5 * sum(log(eigenvalues)); // calculates logdet(K1 \otimes K2)
}
generated quantities{
  //real test = -0.5 * sum(y .* kron_mvprod(Q1,Q2, // calculates -0.5 * y’ (K1 \otimes K2) y
  //         kron_mvprod(transpose(Q1),transpose(Q2),y) ./ eigenvalues))
  //    -0.5 * sum(log(eigenvalues));
}


// how do you sample cmdstanr? generate quantities
