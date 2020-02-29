module DefaultArrays
    import Base.size
    import Base.getindex
    import Base.setindex!
    export DefaultArray
    struct DefaultArray{T,N} <: AbstractArray{T,N}
        default::T
        size::NTuple{N,Int}
        elements::Dict{NTuple{N,Int},T}
    end

    Base.@propagate_inbounds function DefaultArray(default::T, size::NTuple{N,Int})  where {T,N}
        DefaultArray(default, size, Dict{NTuple{N,Int},T}())
    end

    function DefaultArray(default::T, A::AbstractArray{T,N}) where {T,N}
        ret=DefaultArray(default,size(A))
        ret.=A
        ret
    end
    function DefaultArray(A::AbstractArray) 
        DefaultArray(zero(eltype(A)),A)
    end


    Base.size(A::DefaultArray) = A.size


    @inline function checkbounds(A::DefaultArray,I)
        if length(I) != length(A.size) || (!all(1 .<= I .<= A.size)) 
            throw(BoundsError)
        end
    end
    @inline function getindex(A::DefaultArray,i::Int) 
        I=CartesianIndices(A)[i]
        A[I]
    end
    @inline function Base.getindex(A::DefaultArray, I::Int...) 
        @boundscheck checkbounds(A,I)
        get(A.elements, I, A.default)
    end
    @inline function setindex!(A::DefaultArray,v,i::Int) 
        I=CartesianIndices(A)[i]
        A[I]=v
    end
    @inline function Base.setindex!(A::DefaultArray, v, I::Int...) 
        @boundscheck checkbounds(A,I)
        if v == A.default
            haskey(A.elements,I) && delete!(A.elements,I)
            return A[I...]
        end
        A.elements[I] = v
    end

    function eachnondefault(A::DefaultArray)
        (CartesianIndex(x) for x in keys(A.elements) if A.elements[x]!=A.default)
    end

end # module
