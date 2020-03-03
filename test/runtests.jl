using Test
using DefaultArrays

@testset "Basic Tests" begin

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
end

@testset "similar(..) Tests + broadcasting" begin
    M=similar(DefaultArray(1.0),Float64,2,2)

    @test typeof(M)==DefaultArray{Float64,2}
    @test all(@inferred  M.==1.0)
    M[1,2]=0.5
    @test typeof(@inferred M.+2)==DefaultArray{Float64,2}
    M.=M.+M'
    @test all(M.==[2.0 1.5; 1.5 2.0])
    @test typeof(M)==DefaultArray{Float64,2}
end
