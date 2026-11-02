# Self-Control and Performance While Working from Home

## Overview

This contribution implements a Bayesian hierarchical model based on:

Baumann, J., Danilov, A., & Stavrova, O. (2023). *Self-control and performance while working from home*. PLOS ONE, 18(4), e0282862.

https://doi.org/10.1371/journal.pone.0282862

The model reproduces the fully adjusted analysis (Model 2) from the original study using Stan.

## Data

The original dataset contains 786 observations from participants who completed three survey waves.

The data preparation follows the exclusion criteria of the original study:

- Removal of observations with missing ResponseId.
- Exclusion of participants who reported days off (`filter_days_off != 0`).
- Application of the two attention-check criteria (`attention_S1 = 3` and `attention_S2 = 3` and `attention_S3 = 3`).

After applying the exclusion criteria, 774 observations from 258 participants remained.

The variables used in the model were standardized using the means and standard deviations calculated after the exclusion criteria and before complete-case deletion.

Complete-case analysis resulted in a final dataset of **750 observations from 250 participants**, with three observations per participant.

The dataset includes work performance, time, self-control, demographic characteristics, working-from-home characteristics, and personality measures.

## Model

A Bayesian hierarchical linear model was implemented in Stan.

The model includes:

- Time.
- Self-control.
- The time-by-self-control interaction.
- Gender, age, children, income, and education.
- Share of working time spent working from home.
- The Big Five personality dimensions.

Participant-specific random intercepts and random time slopes are included, with a correlated covariance structure.

A non-centred parameterization is used for the hierarchical effects.

The model uses weakly informative normal priors for the fixed effects, half-normal priors for the standard deviation parameters, and an LKJ prior for the correlation structure.

The generated quantities include the correlation matrix and replicated performance observations.

## Posterior Sampling

Posterior inference was performed using RStan.

Sampling configuration:

| Setting | Value |
|---|---:|
| Chains | 4 |
| Iterations per chain | 3,500 |
| Warm-up iterations | 1,000 |
| Post-warm-up draws per chain | 2,500 |
| Total post-warm-up draws | 10,000 |
| Random seed | 1234 |
| Adapt delta | 0.95 |

## Computational Diagnostics

The sampling diagnostics indicate satisfactory convergence and sampling behaviour:

- No divergent transitions were observed.
- All E-BFMI values exceeded 0.2.
- All reported R-hat values were below 1.01.
- Minimum bulk effective sample size was approximately 1,947.
- Minimum tail effective sample size was approximately 3,937.

Some diagnostic values are unavailable for constant elements of the Cholesky factor.

## Reference Posterior Draws

The reduced reference posterior is provided as:

`reference_posteriors/draws/draws/self_control_wfh-work_performance_reduced.json.zip`

It contains:

- 522 sampled parameter variables.
- 4 chains.
- 2,500 post-warm-up draws per chain.
- 10,000 total draws.

The reduction retains the model parameters, including the key coefficients:

- `beta_time`
- `beta_self_control`
- `beta_interaction`

It also retains the participant-level latent variables and other sampled parameters.

Generated quantities, including `performance_rep`, `b`, and `Omega`, are excluded from the reduced reference draws. The observed outcome `performance` remains part of the data object.

## Validation Note

The reference posterior was checked using `posteriordb` version 0.3.6.

The standard `check_reference_posterior_draws()` function does not pass its ESS bounds assertion for these draws.

The package's internal ESS bounds require bulk and tail ESS values to fall within a narrow interval around the total number of draws. The observed ESS values do not satisfy this condition.

This failure should not be interpreted as evidence of poor convergence. The independent sampling diagnostics reported above show no divergences, E-BFMI values above 0.2, and R-hat values below 1.01.

The ESS validation limitation is disclosed rather than overridden. The corresponding `ess_within_bounds` check is recorded as `FALSE` in the reduced reference posterior metadata.

## Software

- RStan 2.39.0
- Stan 2.39.0
- posterior 1.7.0
- posteriordb 0.3.6

## Citation

Baumann, J., Danilov, A., & Stavrova, O. (2023). Self-control and performance while working from home. *PLOS ONE*, 18(4), e0282862.

https://doi.org/10.1371/journal.pone.0282862