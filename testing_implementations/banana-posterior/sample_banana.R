library(rstan)
options(mc.cores = parallel::detectCores())
install.packages("bayesplot")
library(bayesplot)
library(ggplot2)
# define 10-D data (1 top-level y, 9 lower level x's)
setwd("C:/Users/mkami/OneDrive/Pulpit/UNI/posteriordb/testing_implementations/")

banana_data <- list(D = 10, v=100, b=0.03)

code_banana <- "banana-posterior/banana.stan"

fit <- stan(
  code_banana,
  data = banana_data,
  iter = 5000,
  chains = 4,
  seed = 123,
  control = list(adapt_delta = 0.99),
)
summary(fit)
# take Rhat values

rhat_values <- summary(fit)$summary[, "Rhat"]
cat("Rhat values:\n")
print(rhat_values)

cat("Divergent transitions:\n")
divergent_transitions <- get_num_divergent(fit)
print(divergent_transitions)

cat("Effective Sample Size (ESS):\n")
ess_values <- summary(fit)$summary[, "n_eff"]
print(ess_values)

cat("Bayesian Fraction of Missing Information (BFMI):\n")
efmi <- get_bfmi(fit)
print(efmi)

draws <- as.data.frame(fit)

trace_plot <- traceplot(fit, pars = c("y[1]", "y[2]"), inc_warmup = FALSE) + 
  ggplot2::ggtitle("Banana Posterior: Traceplot")
# show plot 
print(trace_plot)
# save trace plot to png
ggsave("banana-posterior/trace_plot.png", trace_plot, width = 10, height = 6, dpi = 300)

# Plotting the 2D density of the first two dimensions
contourplot <- ggplot(draws, aes(x = `y[1]`, y = `y[2]`)) +
  geom_density_2d_filled() + 
  theme_minimal() +
  labs(title = "Banana Posterior Density",
       x = "Dimension 1",
       y = "Dimension 2")
ggsave("banana-posterior/contour_plot.png", contourplot, width = 10, height = 6, dpi = 300)


