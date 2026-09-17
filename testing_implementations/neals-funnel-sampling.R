# sample from the neals funnel models 
library(rstan)
library(bayesplot)
library(ggplot2)
# define 10-D data (1 top-level y, 9 lower level x's)

funnel_data <- list(D = 9)

code_centered = "neals-funnel-centered.stan"
code_noncentered = "neals-funnel-noncentered.stan"

# compile and sample the centered model

?stan
fit_centered <- stan(
  code_centered,
  data = funnel_data,
  iter = 2000,
  chains = 4,
  seed = 123
)

fit_noncentered <- stan(
  code_noncentered, 
  data = funnel_data,
  iter = 2000, 
  chains = 4,
  seed = 123
)


div_centered <- get_num_divergent(fit_centered)
div_noncentered <- get_num_divergent(fit_noncentered)

cat("Centered Divergences:", sum(div_centered), "\n")
cat("Non-centered Divergences:", sum(div_noncentered), "\n")



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
# Note: Stan warns if E-FMI is below 0.2, which aligns with PosteriorDB's strict threshold rule[cite: 1].
print(efmi_centered)
print(efmi_noncentered)
