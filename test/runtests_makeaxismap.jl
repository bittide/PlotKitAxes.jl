module TestMakeAxisMap
  using Cairo
  using PlotKitCairo
  include("../src/maketicks.jl")
  using .MakeTicks
  include("../src/makeaxismap.jl")
  using .MakeAxisMap
  using Test
  include("testset_makeaxismap.jl")
end



using .TestMakeAxisMap
TestMakeAxisMap.main()


