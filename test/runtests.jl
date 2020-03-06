using Test
using DefaultArrays
using LinearAlgebra
@testset "Basic Tests" begin
    A=DefaultArray(Inf,(2,3))
    A[1,2]=2
    @test maximum(A)==Inf
    @test minimum(A)==2
    @test A[3]==A[1,2]
    A[4]=3.0
    @test A[4]==A[2,2]
    @test all(collect(eachnondefault(A)).==[4, 3])
    @test collect(eachnondefault(A,IndexCartesian())) == [CartesianIndex(2, 2), CartesianIndex(1, 2)]
    B=DefaultArray(Inf,(3,))
    B[3]=2
    @test B[3]==2
end

@testset "similar(..) Tests + broadcasting" begin
    M=similar(DefaultArray(1.0),Float64,5,5)

    @test typeof(M)==DefaultArray{Float64,2}
    @test all(@inferred  M.==1.0)
    M[1,2]=0.5
    @test typeof(@inferred M.+2)==DefaultArray{Float64,2}
    M.=M.+M'

    @test all(M.==[2.0 1.5 2.0 2.0 2.0; 1.5 2.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0])
    M[1:2,1:2].=0
    @test all(M.==[0.0 0.0 2.0 2.0 2.0; 0.0 0.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0])
    M[4:5,4:5].=0
    @test all(M.==[0.0 0.0 2.0 2.0 2.0; 0.0 0.0 2.0 2.0 2.0; 2.0 2.0 2.0 2.0 2.0; 2.0 2.0 2.0 0.0 0.0; 2.0 2.0 2.0 0.0 0.0])
    Q=M[2:3,2:3].+I(2)
    @test all(Q.==[1.0 2.0; 2.0 3.0])
    @test typeof(M)==DefaultArray{Float64,2}
    @test all((DefaultArray(0.0,2,2).+true).==1)
end



@testset "Various Constructors" begin
    A=[1 1;0 1]
    M=DefaultArray(A)
    @test all(A.==M)
    @test M==DefaultArray(M)
    ugly=DefaultArray(0,(2,2)) .+ Any[1 1;2 2]
    @test repr((typeof(ugly),ugly))=="(DefaultArray{Int64,2}, [1 1; 2 2])"
end
