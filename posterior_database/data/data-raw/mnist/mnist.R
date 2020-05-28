# zip("raw/t10k-images-idx3-ubyte.zip", files = "raw/t10k-images-idx3-ubyte", flags = "-j")
# zip("raw/train-images-idx3-ubyte.zip", files = "raw/train-images-idx3-ubyte", flags = "-j")
# zip("raw/t10k-labels-idx1-ubyte.zip", files = "raw/t10k-labels-idx1-ubyte", flags = "-j")
# zip("raw/train-labels-idx1-ubyte.zip", files = "raw/train-labels-idx1-ubyte", flags = "-j")

source('read-mnist.R');

unzip("raw/t10k-images-idx3-ubyte.zip", exdir = "raw")
unzip("raw/train-images-idx3-ubyte.zip", exdir = "raw")
unzip("raw/t10k-labels-idx1-ubyte.zip", exdir = "raw")
unzip("raw/train-labels-idx1-ubyte.zip", exdir = "raw")

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
mnist_100 <- list(K = K, J = J,
                  x = x_std[1:N_MAX, ], N = N_MAX, y = yp1[1:N_MAX],
                  xt = xt_std[1:Nt_MAX, ], Nt = Nt_MAX, yt = ytp1[1:Nt_MAX])
save(mnist_100, file = "mnist_100.rda")

mnist <- list(K = K, J = J,
              x = x_std, N = nrow(x_std), y = yp1,
              xt = xt_std, Nt = nrow(xt_std), yt = ytp1)
save(mnist, file = "mnist.rda")
