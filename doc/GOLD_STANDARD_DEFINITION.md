Gold Standard Definition
========================

A gold standard object should contain:
1. 10 000 draws per parameter in the model.
1. Each parameter should have an Rhat (latest version) below 1.01
1. The effective sample size (Bulk and tail) should be larger than 9900 and smaller than 10100.


Computing gold standards
------
Currently we accept two types of gold standard computations, Stan HMC/NUTS and analytical solution/simulations. Although other approaches can also be used (for discrete parameter models).

### Stan HMC/NUTS

Run Stan HMC/NUTS. A good default is
1. 10 chains
1. Thinning of 10
1. 20 000 iter per chain and 10 000 iteration warmup

Check that:
1. There are no divergent transitions in any chain.
