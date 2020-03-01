module DefaultArrays
    import Base.size
    import Base.getindex
    import Base.setindex!
    import Base.@propagate_inbounds
    export DefaultArray,eachnondefault
    struct DefaultArray{T,N} <: AbstractArray{T,N}
        default::T
        size::NTuple{N,Int}
        elements::Dict{NTuple{N,Int},T}
    end

    @propagate_inbounds function DefaultArray(default::T, size::NTuple{N,Int})  where {T,N}
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


    size(A::DefaultArray) = A.size


    @inline function checkbounds(A::DefaultArray,I)
        if length(I) != length(A.size) || (!all(1 .<= I .<= A.size))
            throw(BoundsError)
        end
    end

    @inline getindex(A::DefaultArray{T,1}, i::Int) where T =  _cartesian_getindex(A, i)
    @inline getindex(A::DefaultArray{T,N}, i::Int) where {T,N} =  _scalar_getindex(A, i)
    @inline getindex(A::DefaultArray, I::Int...) =  _cartesian_getindex(A, I...)

    @inline function _cartesian_getindex(A::DefaultArray, I::Int...)
        @boundscheck checkbounds(A,I)
        get(A.elements, I, A.default)
    end
    @inline function _scalar_getindex(A::DefaultArray,i::Int)
        I=Tuple(CartesianIndices(A)[i])
        _cartesian_getindex(A, I...)
    end

    @inline function _cartesian_setindex!(A::DefaultArray, v, I::Int...)
        @boundscheck checkbounds(A,I)
        if v == A.default
            haskey(A.elements,I) && delete!(A.elements,I)
            return A[I...]
        end
        A.elements[I] = v
    end
    @inline function _scalar_setindex!(A::DefaultArray,v,i::Int)
        I=Tuple(CartesianIndices(A)[i])
        _cartesian_setindex!(A, v, I...)
    end
    @inline setindex!(A::DefaultArray{T,1},v, i::Int) where T =  _cartesian_setindex!(A,v, i)
    @inline setindex!(A::DefaultArray{T,N},v, i::Int) where {T,N} =  _scalar_setindex!(A,v, i)
    @inline setindex!(A::DefaultArray,v, I::Int...) =  _cartesian_setindex!(A,v, I...)


    function eachnondefault(A::DefaultArray)
        (CartesianIndex(x) for x in keys(A.elements) if A.elements[x]!=A.default)
    end

end # module
