module DefaultArrays
    import Base.size
    import Base.getindex
    import Base.setindex!
    import Base.@propagate_inbounds
    import Base.IndexStyle
    import Base.BroadcastStyle

    export DefaultArray,eachnondefault
    struct DefaultArray{T,N} <: AbstractArray{T,N}
        default::T
        size::NTuple{N,Int}
        elements::Dict{Int,T}
    end
    import Base.similar
    @inline IndexStyle(::Type{DefaultArray}) = IndexLinear()
    @inline IndexStyle(::DefaultArray) = IndexLinear()

    function DefaultArray(default::T, size::NTuple{N,Int})  where {T,N}
        DefaultArray(default, size, Dict{Int,T}())
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


    @inline size(A::DefaultArray) = A.size

    similar(A::DefaultArray, ::Type{T}, dims::Dims) where {T} = DefaultArray(convert(T,A.default), dims)

    @inline function getindex(A::DefaultArray, i::Int)
        @boundscheck checkbounds(A,i)
        get(A.elements, i, A.default)
    end

    @inline function setindex!(A::DefaultArray, v, i::Int)
        @boundscheck checkbounds(A,i)
        if v == A.default
            haskey(A.elements,i) || delete!(A.elements,i)
        else
            A.elements[i] = v
        end
        v
    end

    @inline function eachnondefault(A::DefaultArray)
        @inbounds (i for i in eachindex(A.elements) if A.elements[i]!=A.default)
    end


    @inline BroadcastStyle(::Type{<:DefaultArray{T}}) where {T} = Broadcast.ArrayStyle{DefaultArray{T}}()
    function similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{DefaultArray{T}}}, ::Type{ElType}) where {ElType,T}
        da = find_defaultarray(bc)
        va,_ =promote(da.default,zero(ElType))
        gooddefault=ifelse(typeof(va)==ElType, va, zero(ElType))
        return DefaultArray(gooddefault::ElType,similar(Array{ElType}, axes(bc)))
    end


    @inline find_defaultarray(bc::Base.Broadcast.Broadcasted) = find_defaultarray(bc.args)
    @inline find_defaultarray(args::Tuple) = find_defaultarray(find_defaultarray(args[1]), Base.tail(args))
    @inline find_defaultarray(x) = x
    @inline find_defaultarray(a::DefaultArray, rest) = a
    @inline find_defaultarray(::Any, rest) = find_defaultarray(rest)
end # module
