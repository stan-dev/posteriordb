Posterior keywords
==================

Below are the definition of some of the keywords used. These are tags added to posterior that we __known__. Hence, there might exist posteriors that should have the keyword where it is currently missing. If you see this, please file an issue and we will try to fix it. 

```easy```: Posteriors that can be computed with standard Stan settings (adapt delta = 0.8) without any divergent transitions for 10 000 draws and on average uses less than 100 leapfrog steps.

```slow```: Posteriors that takes more than 1h to run 1000 iterations/warmup on a standard CPU. The difficulties can be due to different reasons.


```arm book```: Posteriors that can be found in Gelman, A., & Hill, J. (2006). Data analysis using regression and multilevel/hierarchical models. Cambridge university press.

```pathfinder paper```: Posteriors used in Zhang, L., Carpenter, B., Gelman, A., & Vehtari, A. (2022). Pathfinder: Parallel quasi-Newton variational inference. Journal of Machine Learning Research, 23(306), 1-49.

```bpa book```: Posteriors translated by Hiroki Itô from Kéry, M., & Schaub, M. (2011). Bayesian population analysis using WinBUGS: a hierarchical perspective. Academic Press.

```stan benchmark```: Early posteriors used in the Stan repository "Benchmark Models for Evaluating Algorithm Accuracy". The repository can be found here:
https://github.com/stan-dev/stat_comp_benchmarks

```stan case study```: Posteriors for Stan cases studies. See the following URL for more information:
https://mc-stan.org/users/documentation/case-studies.html

```warmup paper```: Posteriors used in Bales, B., Pourzanjani, A., Vehtari, A., & Petzold, L. (2019). Selecting the metric in Hamiltonian monte carlo. arXiv preprint arXiv:1905.11916.

```bugs examples``` Posteriors from BUGS example models and data. See the following URL for more information: https://github.com/stan-dev/example-models/tree/master/bugs_examples

```stan examples``` Posteriors from Stan examples at: https://github.com/stan-dev/example-models
