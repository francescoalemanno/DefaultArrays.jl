using Test
using DefaultArrays
A=DefaultArray(Inf,(2,3))
A[1,2]=2
@test maximum(A)==Inf
@test minimum(A)==2
@test A[3]==A[1,2]
A[4]=3.0
@test A[4]==A[2,2]
B=DefaultArray(Inf,(3,))
B[3]=2
@test B[3]==2
