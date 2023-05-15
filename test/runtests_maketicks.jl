

module TestMakeTicks
  using Cairo
  using PlotKitCairo
  include("../src/maketicks.jl")
  using .MakeTicks
  using Test
  include("testset_maketicks.jl")
end

using .TestMakeTicks
TestMakeTicks.main()


