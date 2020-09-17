Reference Posterior Definition
========================

The purpose of the reference posterior definition is to define the criteria for checking that we have approximately independent draws from the true underlying posterior distribution.

A reference posterior should have:
1. 10 000 draws per parameter in the model.
1. Each parameter should have an Rhat (see [arXiv](https://arxiv.org/abs/1903.08008)) below 1.01.
1. The effective sample size (bulk and tail) should fall within a probability bound of 0.95. See details below.
1. All Expected Fraction of Missing Information (E-FMI) is below 0.2
1. Efficient sample size (ESS) / iteration > 0.0001


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




Computing parameter ESS bounds
------

The variability of ESS estimate is relatively high, so to assert that we have a reasonable bound on the ESS values, we have simulated the distribution for ESS bulk and ESS tail (see [arXiv](https://arxiv.org/abs/1903.08008)) based on 10 000 normal draws. See `ess_bounds()` for how bounds are chosen.
