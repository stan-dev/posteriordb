using Turing
using LinearAlgebra

@model function nes(N, partyid7, real_ideo, race_adj, educ1, gender, income, age_discrete)

    sigma ~ Turing.FlatPos(0)
    beta ~ filldist(Turing.Flat(), 9)

    age30_44 = age_discrete .== 2
    age45_64 = age_discrete .== 3
    age65up = age_discrete .== 4
    

    partyid7 ~ MvNormal(beta[1] .+ beta[2] .* real_ideo .+ beta[3] .* race_adj .+
                        beta[4] .* age30_44 .+ beta[5] .* age45_64 .+
                        beta[6] .* age65up .+ beta[7] .* educ1 .+ beta[8] .* gender .+
                        beta[9] .* income, sigma^2 .* I)
end