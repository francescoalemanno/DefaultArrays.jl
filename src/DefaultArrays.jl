module DefaultArrays
import Base.size
import Base.getindex
import Base.setindex!
import Base.@propagate_inbounds
import Base.IndexStyle
import Base.BroadcastStyle

export DefaultArray, eachnondefault
struct DefaultArray{T,N} <: AbstractArray{T,N}
    default::T
    size::NTuple{N,Int}
    elements::Dict{Int,T}
end
import Base.similar

@inline IndexStyle(::DefaultArray) = IndexLinear()

function DefaultArray(default::T, size::NTuple{N,Int}) where {T,N}
    DefaultArray(default, size, Dict{Int,T}())
end

function DefaultArray(default, size::Int...)
    DefaultArray(default, size)
end

function DefaultArray(default::T, A::AbstractArray{T,N}) where {T,N}
    ret = DefaultArray(default, size(A))
    ret .= A
    ret
end
function DefaultArray(A::AbstractArray)
    DefaultArray(zero(eltype(A)), A)
end
function DefaultArray(A::DefaultArray)
    A
end

@inline size(A::DefaultArray) = A.size

similar(A::DefaultArray, ::Type{T}, dims::Dims) where {T} =
    DefaultArray(convert(T, A.default), dims)

@inline function getindex(A::DefaultArray, i::Int)
    @boundscheck checkbounds(A, i)
    get(A.elements, i, A.default)
end

@inline function setindex!(A::DefaultArray, v, i::Int)
    @boundscheck checkbounds(A, i)
    if v == A.default
        haskey(A.elements, i) && delete!(A.elements, i)
    else
        A.elements[i] = v
    end
    v
end

@inline function eachnondefault(A::DefaultArray)
    eachnondefault(A,IndexStyle(A))
end

@inline function eachnondefault(A::DefaultArray,Type::IndexLinear)
    @inbounds (i for i in eachindex(A.elements) if A.elements[i] != A.default)
end

@inline function eachnondefault(A::DefaultArray,Type::IndexCartesian)
    B=CartesianIndices(A)
    @inbounds (B[i] for i in eachindex(A.elements) if A.elements[i] != A.default)
end

@inline BroadcastStyle(::Type{<:DefaultArray{T}}) where {T} =
    Broadcast.ArrayStyle{DefaultArray{T}}()

function similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{DefaultArray{T}}}, ::Type{ElType}) where {ElType,T}
    da = find_defaultarray(bc)
    va, _ = promote(da.default, zero(ElType))
    gooddefault = ifelse(typeof(va) == ElType, va, zero(ElType))
    return DefaultArray(gooddefault::ElType, size(bc))
end


@inline find_defaultarray(bc::Base.Broadcast.Broadcasted) = find_defaultarray(bc.args)
@inline find_defaultarray(bc::Base.Broadcast.Extruded) = find_defaultarray(bc.x)
@inline find_defaultarray(args::Tuple) = find_defaultarray(find_defaultarray(args[1]), Base.tail(args))
@inline find_defaultarray(x) = x
@inline find_defaultarray(a::DefaultArray, rest) = a
@inline find_defaultarray(a::Any, rest) = find_defaultarray(rest)

"""
eachnondefault(A::DefaultArray, indexstyle = IndexLinear())

Create an generator object for visiting each index of a `DefaultArray A` containing a non-default value, in an efficient manner.

Example:
```julia
julia> A = DefaultArray(1,[1 2; 3 4]);

julia> for i in eachnondefault(A) # linear indexing
           println(i, " ", A[i])
       end
4 4
2 3
3 2
```
notice how the value "1" has been skipped, since we set 1 as the default value.
```julia
julia> A = DefaultArray(1,[1 2; 3 4]);

julia> for i in eachnondefault(A,IndexCartesian()) # cartesian indexing
           println(i, " ", A[i])
       end
CartesianIndex(2, 2) 4
CartesianIndex(2, 1) 3
CartesianIndex(1, 2) 2
```
"""
eachnondefault

"""
DefaultArray(default, size...)

Create a DefaultArray

Example 1:
```julia
julia> DefaultArray("X",3,3)
3×3 DefaultArray{String,2}:
 "X"  "X"  "X"
 "X"  "X"  "X"
 "X"  "X"  "X"
```

Example 2:
```julia
julia> DefaultArray(false,3,4)
3×4 DefaultArray{Bool,2}:
 0  0  0  0
 0  0  0  0
 0  0  0  0
```

DefaultArray(default, A::AbstractArray)

Example 3:
```julia
DefaultArray(false,rand(Bool,5,5))
5×5 DefaultArray{Bool,2}:
1  0  0  1  0
1  1  1  1  1
1  1  1  0  0
0  1  0  0  1
0  0  1  1  0
```
"""
DefaultArray
end # module
