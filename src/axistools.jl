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


#
# pure functions for handling axis, ticks, limits and labels
#

module AxisTools

using ..Cairo
using ..PlotKitCairo
using ..Basic

export Axis, AxisMap, AxisOptions, AxisStyle, Layout, Ticks, best_labels, best_ticks, drawaxis, fit_box_around_data, get_tick_extents, set_window_size_from_data, setclipbox



(ax::AxisMap)(p::Point) = ax.f(p)
(ax::AxisMap)(plist::Array{Point}) = ax.f.(plist)


function ifnotmissingticks(a::Ticks, b::Ticks)
    return Ticks(ifnotmissing(a.xticks, b.xticks),
                 ifnotmissing(a.xtickstrings, b.xtickstrings),
                 ifnotmissing(a.yticks, b.yticks),
                 ifnotmissing(a.ytickstrings, b.ytickstrings))
end



##############################################################################
# axis




##############################################################################
# ticks




##############################################################################
# axis_builder




##############################################################################
# draw_axis


##############################################################################



end

