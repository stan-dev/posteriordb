Gold Standard Definition
========================

The purpose of the gold standard definition is to define the criteria for cbelieving that we have approximately independent draws from the true underlying posterior distribution.

A gold standard should contain:
1. 10 000 draws per parameter in the model.
1. Each parameter should have an Rhat (see [arxiv](https://arxiv.org/abs/1903.08008)) below 1.01
1. The effective sample size (Bulk and tail) should be larger than 9900 and smaller than 10100.


Computing gold standards
------
Currently we accept two types of gold standard computations, Stan HMC/NUTS and analytical solution/simulations. Although other approaches can also be used in special circumstances (e.g., for discrete parameter models) if a clear point can be made that this is necessary.

### Stan HMC/NUTS sampling

Run Stan HMC/NUTS. A good default is
1. 10 chains
1. Thinning of 10
1. 20 000 iter per chain and 10 000 iteration warmup

Check that:
1. There are no divergent transitions in any chain.

### Analytical

If it is possible to analytically compute the true posterior we can just make draws from he true posterior distribution.
