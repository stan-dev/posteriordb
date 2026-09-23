# sample from the neals funnel models 
library(rstan)
options(mc.cores = parallel::detectCores())
library(bayesplot)
install.packages("bayesplot")
library(ggplot2)
# define 10-D data (1 top-level y, 9 lower level x's)
setwd("/home/mkami/UNI/posteriordb/testing_implementations")
funnel_data <- list(D = 9)

packageVersion("rstan")
code_centered <- "neals-funnel-centered.stan"
code_noncentered <- "neals-funnel-noncentered.stan"

# compile and sample the centered model

?stan
fit_centered <- stan(
  code_centered,
  data = funnel_data,
  iter = 2000,
  chains = 4,
  seed = 123
)
draws_centered <- as.data.frame(fit_centered)
write.csv(draws_centered, "draws_centered.csv", row.names = FALSE)

fit_noncentered <- stan(
  code_noncentered,
  data = funnel_data,
  iter = 2000,
  chains = 4,
  seed = 123
)

draws_noncentered <- as.data.frame(fit_noncentered)
write.csv(draws_noncentered, "draws_noncentered.csv", row.names = FALSE)

div_centered <- get_num_divergent(fit_centered)
div_noncentered <- get_num_divergent(fit_noncentered)

cat("Centered Divergences:", sum(div_centered), "\n") # 3
cat("Non-centered Divergences:", sum(div_noncentered), "\n") # 0



cat("\n--- Centered Model Summary ---\n")
print(fit_centered, pars = c("y", "x[1]"))

cat("\n--- Non-centered Model Summary ---\n")
print(fit_noncentered, pars = c("y", "x[1]"))


# Traceplots show the path the algorithm took through the parameter space.
trace_centered <- traceplot(fit_centered, pars = c("y", "x[1]"), inc_warmup = FALSE) + 
  ggplot2::ggtitle("Centered: Sticky, Poor Mixing")
trace_noncentered <- traceplot(fit_noncentered, pars = c("y", "x[1]"), inc_warmup = FALSE) + 
  ggplot2::ggtitle("Non-centered: Smooth, Healthy Mixing")

# Display them (you can run these one by one in your console)
trace_centered
trace_noncentered



# --- 3. The Pairs Plot (Visualizing the Funnel & Divergences) ---
# This is the most powerful plot for showing Neal's Funnel in action.
pairs(fit_centered, pars = c("y", "x[1]"))
# Note: rstan's pairs plot automatically highlights divergent transitions as red points!




# Check the Expected Fraction of Missing Information.
# PosteriorDB strictly requires E-FMI to be < 0.2[cite: 1].
efmi_centered <- get_bfmi(fit_centered)
efmi_noncentered <- get_bfmi(fit_noncentered)

cat("\n--- E-FMI (Must be < 0.2 to fail the check, wait, > 0.2 is good, low is bad) ---\n")
# Note: Stan warns if E-FMI is below 0.2, which aligns with PosteriorDB's strict threshold rule.
print(efmi_centered)
print(efmi_noncentered)

?paste0
# isolate free parameters 
free_param_names <- c("y", paste0("x_raw[", 1:9, "]"))

###### Generate fixed evaluation points for the implementation check
set.seed(23)
eval_indices <- sample(1:nrow(draws_centered), 100)
eval_points_centered <- draws_centered[eval_indices, 1:(ncol(draws_centered)-1)]
eval_points_noncentered <- draws_noncentered[eval_indices, free_param_names]

# extract log-densities and gradients at these exact points
log_probs_centered <- numeric(100)
grads_centered <- matrix(NA, nrow=100, ncol=ncol(eval_points_centered))
colnames(grads_centered) <- colnames(eval_points_centered)

log_probs_noncentered <- numeric(100)
grads_noncentered <- matrix(NA, nrow=100, ncol=ncol(eval_points_noncentered))
colnames(grads_noncentered) <- colnames(eval_points_noncentered)


for (i in 1:100) {
  pt <- as.numeric(eval_points_centered[i, ])
  log_probs_centered[i] <- log_prob(fit_centered, pt)
  grads_centered[i, ] <- grad_log_prob(fit_centered, pt)
}

for (i in 1:100) {
  pt <- as.numeric(eval_points_noncentered[i, ])
  log_probs_noncentered[i] <- log_prob(fit_noncentered, pt)
  grads_noncentered[i, ] <- grad_log_prob(fit_noncentered, pt)
}

folder_path <- "neals_draws_rstan"
write.csv(eval_points_centered, file.path(folder_path, "eval_points_centered.csv"), row.names = FALSE)
write.csv(log_probs_centered, file.path(folder_path, "log_probs_centered.csv"), row.names = FALSE)
write.csv(grads_centered, file.path(folder_path, "grads_centered.csv"), row.names = FALSE)

write.csv(eval_points_noncentered, file.path(folder_path, "eval_points_noncentered.csv"), row.names = FALSE)
write.csv(log_probs_noncentered, file.path(folder_path, "log_probs_noncentered.csv"), row.names = FALSE)
write.csv(grads_noncentered, file.path(folder_path, "grads_noncentered.csv"), row.names = FALSE)


timing_centered <- get_elapsed_time(fit_centered)
timing_noncentered <- get_elapsed_time(fit_noncentered)
write.csv(timing_centered, "neals_draws_rstan/timing_centered.csv", row.names = FALSE)
write.csv(timing_noncentered, "neals_draws_rstan/timing_noncentered.csv", row.names = FALSE)
