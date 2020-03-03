# DefaultArrays

[![Build Status](https://travis-ci.org/francescoalemanno/DefaultArrays.jl.svg?branch=master)](https://travis-ci.org/francescoalemanno/DefaultArrays.jl)

Julia array type supporting a default value, useful for storing very sparse information in a space efficient manner, the internal design uses "Dict" for storage

### Installation:
Since this package is not registered (at the moment) do:
```julia
using Pkg
pkg"add https://github.com/francescoalemanno/DefaultArrays.jl.git";
```

### Usage:
It can be used like any other common julia array:
```julia
M=DefaultArray(0.0,100,100) #0.0 is the default value
M.=rand([zeros(50);1],100,100)

for i in eachnondefault(M)
    M[i]=rand()
end
Q=sin.(M)

sum(Q)  #->  some random value
length(Q.elements) #-> MUCH less space occupied than 100*100 = 10000
```



original idea of Tamas K. Papp @ https://github.com/tpapp
