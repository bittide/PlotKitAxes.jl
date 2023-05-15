

module TestDrawAxis
  using Cairo
  using PlotKitCairo
  include("../src/maketicks.jl")
  using .MakeTicks
  include("../src/makeaxismap.jl")
  using .MakeAxisMap
  include("../src/drawaxis.jl")
  using .DrawAxis
  using Test
  include("testset_drawaxis.jl")
end



using .TestDrawAxis
TestDrawAxis.main()


