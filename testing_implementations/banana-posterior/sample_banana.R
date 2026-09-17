library(rstan)
library(bayesplot)
library(ggplot2)
# define 10-D data (1 top-level y, 9 lower level x's)
setwd("/home/mkami/UNI/posteriordb/testing_implementations")

banana_data <- list(D = 2, v=100, b=0.03)

code_banana <- "banana-posterior/banana.stan"

fit <- stan(
  code_banana,
  data = banana_data,
  iter = 2000,
  chains = 4,
  seed = 123,
  control = list(adapt_delta = 0.95),
)
summary(fit)

draws <- as.data.frame(fit)

trace_plot <- traceplot(fit, pars = c("y[1]", "y[2]"), inc_warmup = FALSE) + 
  ggplot2::ggtitle("Banana Posterior: Traceplot")
trace_plot

# Plotting the 2D density of the first two dimensions
contourplot <- ggplot(draws, aes(x = `y[1]`, y = `y[2]`)) +
  geom_density_2d_filled() + 
  theme_minimal() +
  labs(title = "Banana Posterior Density",
       x = "Dimension 1",
       y = "Dimension 2")
contourplot


