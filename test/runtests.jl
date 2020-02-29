using Test
using DefaultArrays
A=DefaultArray(Inf,(2,2))
A[1,2]=2
@test maximum(A)==Inf
@test minimum(A)==2


