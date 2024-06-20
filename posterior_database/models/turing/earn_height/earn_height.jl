using Turing, LinearAlgebra

@model function earn_height(N, earn, height)
  beta ~ filldist(Turing.Flat(), 2)
  sigma ~ Turing.FlatPos(0)
  
  earn ~ MvNormal(beta[1] .+ beta[2] .* height, sigma^2*I)
end