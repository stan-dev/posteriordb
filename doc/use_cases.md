# Use case scenarios for posteriordb

posteriordb has different uses. Below is list of example use cases we have been thinking and what features are important in each use case

## Testing implementations of inference algorithms with asymptotically decreasing bias and variance

If an inference algorithm has asymptotically decreasing bias and variance, then an implementation should have decreasing error compared to true posterior summaries.

True summaries can be computed analytically for some simpler models, which are not necessarily that interesting from the modelling perspective, but are useful for detecting problems as the truth is known exactly. It is easiest to compare estimated and true posterior moments and quantiles for scalar quantities. For closed form marginals we can also use QQ-plots and ECDF-plots for visual exploration of unexpected discrepancies. Uniformity of PIT tests can be used to test the whole marginal, although the interpretation of different uniformity tests is more complex than point estimate comparisons.

The set of applicable models can be expanded by including models which don't have closed form marginals, but for which we have high confidence that we can obtain draws from the true posterior. The ideal would be to use independent draws, which is feasible for some models for which the posterior factorizes to series of closed form distributions and we can obtain independent draws from each of those. We can also use MCMC for posteriors which are known to be well behaving and that given MCMC has been shown to be reliable for those posteriors. For example, dynamic HMC, is known to work well for many models. In case of MCMC, the chains should be thinned so that the draws are approximately independent to make the further comparisons easier. When using MC or MCMC to obtain the reference posterior, a very large number of draws should be used in this use case. Monte Carlo standard errors can be used to check the accuracy of the empirical expectations. A very large number of draws could be used to compute some set of posterior moments and quantiles, and just a large number of posterior draws could be stored to enable QQ- and ECDF-plots to analyse the properties of the discrepancies. 

In cases where we are not certain whether we can get reliable posterior draws, simulation based calibration (SBC) should be used instead.

For this use case we would have a smaller set of posteriors as the requirements are very strict. Initial set comes from https://github.com/stan-dev/stat_comp_benchmarks. This set will be gradually expanded.

In this use case we assume an algorithm should work well for all posteriors in the strict testing set.

This kind of strict testing could be run every time before new release and every time after any algorithm changes in a development branch.

## Code speed testing

If the above strict test is passed, the same test can be used for timing comparisons.

Even if the algorithm doesn't change, various changes in, for example, Stan math library, autodiff, parallelization implementation, and compiler options can affect the computation speed. The small test set can be used to test code speed by running earlier and new version in the same computer. See example in https://github.com/stan-dev/performance-tests-cmdstan

## Efficiency comparisons of inference algorithms with asymptotically decreasing bias and variance

Assuming we have different inference algorithms, small variants of some specific algorithm, for example, having different warm-up adaptations in dynamic HMC, and the implementations of these have passed the above strict checking. We are interested in testing efficiency of these algorithms with more complex posteriors. Now to make the set of more interesting models have enough variety, we assume that careful use dynamic HMC, convergence diagnostics, and SBC will provide the reference posterior. We don't claim these reference posteriors would be 100% correct, and if your new algorithm produces different result there is reason to check which result is more likely to closer to true posterior. In efficiency comparisons we assume the algorithms are working, that is, they have passed the previous more strict tests with smaller set of models. For a bigger set of models we don't make as strict tests, but it is useful to make some checks that produced  posterior is close to the reference posterior. The main interest in this use case is however in inference diagnostics and efficiency measures. Inference diagnostics should detect if the tested inference algorithm is not able to produce accurate results. An inference algorithm can be useful if it works fast for some set of models and it can be diagnosed when it doesn't work. Useful efficiency measures are effective sample size divided by the number of log-density and gradient evaluations and effective sample size per second. The first one is useful when comparing high-level algorithms as it doesn't care how well log-density and gradient evaluations are optimized and the second one can be useful when comparing algorithms where the choice of algorithm can affect the computational cost of log-density and gradient evaluation (e.g. use of Laplace integration over the latent values)-

The bigger set will be filled with models from https://github.com/stan-dev/example-models 
and models used, e.g. in https://arxiv.org/abs/1905.11916

## Explorative analysis of algorithms

The posteriors have keywords describing them. This can be used to find in which cases some algorithm fails or is significantly more efficient than other. These keywords can be like "unimodal", "multimodal", "funnel", "low_correlation", "high_correlation". In addition, the dimensionality of parameter space is known. This makes it possible to do explorative analysis, first finding in which cases algorithm fails and then comparing to the reference posterior in which way it is failing, or first finding in which cases algorithm efficiency is much different than for others (e.g. low efficiency for "high_correlation" posteriors) and then analysing the reasons.

## Testing implementations of inference algorithms with asymptotic bias

Sometimes it is useful to use algorithms which have asymptotically non-negligible bias. In this use case we can examine in which cases the inference error is acceptable. It is also possible that the error can be quite big for some posterior quantities, but for example if the focus is in the predictions we could focus on looking at the inference error only for predictions.

## Developing new algorithms for interesting models

We aim to include in posteriordb also challenging models and posteriors for which we don't know yet efficient algorithms, e.g. posteriors for which we know the current dynamic HMC in Stan is inefficient. Some of the posteriors might be such that dynamic HMC needs to be run very very long time, and some might be such that even if dynamic HMC would be best we know we assume it's still getting stuck in local modes. We welcome interesting challenging examples even without a reference posterior or if the reference posterior has been computed with model specific algorithm. Having just models in the database, makes it faster for others to experiment with challenging models, too.

## Code examples

Whenever there is some code in internet, it is possible that someone copies that. We aim to have best practices Stan code and priors, so that if someone copies one of our examples we don't spread bad examples. We may also sometimes include models with bad priors (e.g. some models copied from BUGS examples) as they can provide good test posteriors (e.g. weak identifiability) for convergence diagnostics, but such bad priors should be accompanied with a comment stating that they are bad priors.

