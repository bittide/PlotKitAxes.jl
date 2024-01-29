
#
# run using Pkg.test("PlotKitAxes")
#
#
# or using
#
#  cd PlotKitAxes.jl/test
#  julia
#  include("runtests.jl")
#
#
# or individually, e.g.
#
#  cd PlotKitAxes.jl/test
#  julia
#  include("runtests_axisdrawables.jl")
#
#

include("runtests_axisbuilder.jl")
include("runtests_axisdrawables.jl")
include("runtests_drawaxis.jl")
include("runtests_makeaxismap.jl")
include("runtests_maketicks.jl")


