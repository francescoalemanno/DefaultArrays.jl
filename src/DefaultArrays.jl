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
    import Base.similar


    @propagate_inbounds function DefaultArray(default::T, size::NTuple{N,Int})  where {T,N}
        DefaultArray(default, size, Dict{NTuple{N,Int},T}())
    end
    function DefaultArray(default,size::Int...)
        DefaultArray(default, size)
    end
    function DefaultArray(default::T, A::AbstractArray{T,N}) where {T,N}
        ret=DefaultArray(default,size(A))
        ret.=A
        ret
    end
    function DefaultArray(A::AbstractArray)
        DefaultArray(zero(eltype(A)),A)
    end
    function DefaultArray(A::DefaultArray)
        DefaultArray(A.default,A)
    end


    size(A::DefaultArray) = A.size

    similar(A::DefaultArray, ::Type{T}, dims::Dims) where {T} = DefaultArray(convert(T,A.default), dims)

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
        if v == A.default && haskey(A.elements,I)
            delete!(A.elements,I)
        else
            A.elements[I] = v
        end
        v
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

    import Base.BroadcastStyle
    BroadcastStyle(::Type{<:DefaultArray{T}}) where {T} = Broadcast.ArrayStyle{DefaultArray{T}}()
    function similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{DefaultArray{T}}}, ::Type{ElType}) where {ElType,T}
        da = find_defaultarray(bc)
        va,vb=promote(da.default,zero(ElType))
        if typeof(va)==ElType
            return DefaultArray(va,similar(Array{ElType}, axes(bc)))
        end
        return DefaultArray(zero(ElType),similar(Array{ElType}, axes(bc)))
    end


    find_defaultarray(bc::Base.Broadcast.Broadcasted) = find_defaultarray(bc.args)
    find_defaultarray(args::Tuple) = find_defaultarray(find_defaultarray(args[1]), Base.tail(args))
    find_defaultarray(x) = x
    find_defaultarray(a::DefaultArray, rest) = a
    find_defaultarray(::Any, rest) = find_defaultarray(rest)
end # module
