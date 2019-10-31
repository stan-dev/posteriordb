Gold Standard Definition
========================

A gold standard object should contain:
1. 10 000 draws per parameter in the model.
1. Each parameter should have an Rhat (latest version) below 1.01
1. The effective sample size should be larger than 9900.

In practice, this can be achieved using Stan and NUTS and check the diagnoses to asses that:
1. There are no divergent transitions in any chain.
1. Each parameter should have an Rhat (latest version) below 1.01
1. The effective sample size should be larger than 9900.
