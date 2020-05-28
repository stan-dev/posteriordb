source('read-mnist.R');

load_mnist();


standardize <- function(u) (u - mean(u)) / sd(u);

yp1 <- train$y + 1;
K <- max(yp1);
N <- length(yp1);

x_std <- train$x;
M <- dim(x_std)[2];
J <- 50;
for (k in 1:K) {
  if (sum(x_std[ , k] != 0) > 1)
    x_std[ , k] <- standardize(x_std[ , k]);
}

xt_std <- test$x;
for (k in 1:K) {
  if (sum(x_std[ , k] != 0) > 1)
    xt_std[ , k] <- (xt_std[ , k] - mean(x_std[ , k])) / sd(x_std[ , k]);
}
ytp1 <- test$y + 1;
Nt <- dim(xt_std)[1];

# trim data *****************************************
N_MAX = 100;

Nt_MAX = 100;
mnist_data <- list(K = K, J = J,
                   x = x_std[1:N_MAX, ], N = N_MAX, y = yp1[1:N_MAX],
                   xt = xt_std[1:Nt_MAX, ], Nt = Nt_MAX, yt = ytp1[1:Nt_MAX]);
