
module DataSet


using ..PlotKitCairo: Point

export DataSet, Series


mutable struct DataSet
    d::Array{Series}
end

mutable struct Series
    p::Vector{Point}
end



end

