# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module PlotKitAxes


##############################################################################
# submodules

# The included modules are sorted by dependency.
using Cairo
using PlotKitCairo

# MakeTicks, MakeAxisMap and DrawAxis are ordered by dependency
include("maketicks.jl")
using .MakeTicks

include("makeaxismap.jl")
using .MakeAxisMap

include("drawaxis.jl")
using .DrawAxis

include("axisdrawables.jl")
using .AxisDrawables

include("axisbuilder.jl")
using .AxisBuilder



##############################################################################
function reexport(m)
    for a in names(m)
        eval(Expr(:export, a))
    end
end


reexport(PlotKitCairo)
reexport(MakeTicks)
reexport(MakeAxisMap)
reexport(DrawAxis)
reexport(AxisDrawables)
reexport(AxisBuilder)



end

