# Builds the kidney_data list used by the frailty_cox_replication model
# from the kidney dataset of the R survival package.

k <- survival::kidney
k <- k[order(k$time), ]

# Covariates as in McGilchrist & Aisbett (1991): age in years, sex (1 = male, 2 = female),
# 0/1 indicators for disease types GN, AN and PKD (Other is the baseline).
X <- cbind(age = k$age,
           sex = k$sex,
           GN  = as.integer(k$disease == "GN"),
           AN  = as.integer(k$disease == "AN"),
           PKD = as.integer(k$disease == "PKD"))

kidney_data <- list(N     = nrow(k),
                    M     = length(unique(k$id)),
                    P     = ncol(X),
                    t     = k$time,
                    D     = k$status,
                    pid   = k$id,
                    X     = X,
                    sigma = 1)
