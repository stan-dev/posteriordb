using Turing
using FillArrays
using LinearAlgebra

@model function eight_schools_noncentered(J, y, sigma)
    tau ~ Truncated(Cauchy(0, 5), 0, Inf)
    mu ~ Normal(0, 5)

    theta_trans ~ MvNormal(Fill(0, J), I)
    theta := [tau * s + mu for s in theta_trans]
        
    y ~ MvNormal(theta, sqrt.(sigma))
end