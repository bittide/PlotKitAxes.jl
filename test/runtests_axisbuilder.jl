


##############################################################################
module TestAxisBuilder
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
include("../src/axisbuilder.jl")
using .AxisBuilder
using Test
include("testset_axisbuilder.jl")
end



using .TestAxisBuilder
TestAxisBuilder.main()




