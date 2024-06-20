using Turing 
using LinearAlgebra
using FillArrays

@model function eight_schools_centered(J, y, sigma)
    tau ~ Truncated(Cauchy(0, 5), 0, Inf)
    mu ~ Normal(0, 5)

    theta ~ MvNormal(Fill(mu, J), sqrt(tau)*I)
    y ~ MvNormal(theta, Diagonal(sqrt.(sigma)))
end
