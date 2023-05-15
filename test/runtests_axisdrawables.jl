

module TestAxisDrawables
using Cairo
using PlotKitCairo
include("../src/maketicks.jl")
using .MakeTicks
include("../src/makeaxismap.jl")
using .MakeAxisMap
include("../src/drawaxis.jl")
using .DrawAxis
include("../src/axisdrawables.jl")
using .AxisDrawables

using Test
include("testset_axisdrawables.jl")
end



using .TestAxisDrawables
TestAxisDrawables.main()




