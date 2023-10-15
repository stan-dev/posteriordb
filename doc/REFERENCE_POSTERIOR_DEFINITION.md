Reference Posterior Definition
========================

The purpose of the reference posterior definition is to define the criteria for checking that we have approximately independent draws from the true underlying posterior distribution.

A reference posterior should have:
1. 10 000 draws per parameter in the model.
1. An Rhat (see [Vehtari et al. (2021)](https://doi.org/10.1214/20-BA1221)) below 1.01 for all parameters.
1. Approximately independent draws, that is, all parameters have an autocorrelation at lag 1 that is less than 0.05 (see, e.g., [Vehtari et al. (2021)](https://doi.org/10.1214/20-BA1221))).
1. All Expected Fraction of Missing Information (E-FMI) is below 0.2 (see section 6.1 of [A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434))
1. No divergent transitions if HMC is used (see [Stan Reference Manual](https://mc-stan.org/docs/reference-manual/divergent-transitions.html))


Computing Reference Posteriors Draws
------
We currently use two reference posterior computation methods, Stan HMC/NUTS, and analytical solution/simulations. Although other approaches can also be used in special circumstances (e.g., for discrete parameter models), if a clear argument can be made that this is necessary.

### Stan HMC/NUTS sampling

Run Stan HMC/NUTS. A good default is
1. 10 chains
1. Thinning of 10
1. 20 000 iterations per chain and 10 000 iteration warmup

Check that:
1. There are no divergent transitions in any chain after warmup.

### Analytical

If it is possible to compute the true posterior analytically, we can make draws from the posterior distribution directly.

