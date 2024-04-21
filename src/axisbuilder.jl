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

module AxisBuilder

using PlotKitCairo: Drawable, Box, Point, PointList, Drawable, Color, getbox, inbox, expand_box, iffinite, ifnotmissing, remove_data_outside_box, scale_box, setoptions!, smallest_box_containing_data

using ..AxisDrawables: AxisDrawable, AxisDrawables
using ..DrawAxis: Axis, DrawAxis, AxisStyle
using ..MakeTicks: Ticks, get_tick_extents
using ..MakeAxisMap: AxisMap, @plotfns

export AxisOptions, colorbar



#
# AxisOptions is passed to the Axis constructor,
# which creates the Axis object above. It contains the style
# information for drawing the axis, in AxisStyle
# and the information used to construct the AxisMap, and the layout
# within the window.
#
# AxisOptions are set by the user
# They are only used to create the Axis object.
#
Base.@kwdef mutable struct AxisOptions
    xmin = -Inf
    xmax = Inf
    ymin = -Inf
    ymax = Inf
    xdatamargin = 0
    ydatamargin = 0
    xwidenfactor = 1
    ywidenfactor = 1
    widthfromdata = 0 
    heightfromdata = 0
    width = 800
    height = 600
    lmargin = 80
    rmargin = 80
    tmargin = 80
    bmargin = 80
    xidealnumlabels = 10
    yidealnumlabels = 10
    yoriginatbottom = true
    xticksatright = false
    axisequal = false
    windowbackgroundcolor = Color(:white)
    drawbackground = true
    drawaxis = true
    ticks = Ticks()
    axisstyle = AxisStyle()
    tickbox = Box()
    axisbox = Box()
    tight = false
end

##############################################################################


function DrawAxis.Axis(p::PointList, ao::AxisOptions)
    ignore_data_outside_this_box = getbox(ao)
    
    # tickbox is set to a box that contains the data
    # so if ignore_data_outside_this_box specifies limits on x,
    # then the data is used to determine limits on y
    # and these limits go into tickbox
    #
    boxtmp = fit_box_around_data(p, ignore_data_outside_this_box)
    return Axis(boxtmp, ao)
end

function DrawAxis.Axis(ao::AxisOptions)
    boxtmp = iffinite(getbox(ao), Box(0,1,0,1))
    return Axis(boxtmp, ao)
end


function DrawAxis.Axis(databox::Box, ao::AxisOptions)
    tickbox = ifnotmissing(ao.tickbox,
                           scale_box(expand_box(databox, ao.xdatamargin, ao.ydatamargin),
                                     ao.xwidenfactor, ao.ywidenfactor))

    # tickbox used to define the minimum area which the ticks
    # are guaranteed to contain
    # Ticks is a set of ticks chosen to be pretty, and to contain tickbox
    ticks = ifnotmissing(ao.ticks, Ticks(tickbox,  ao.xidealnumlabels, ao.yidealnumlabels))

    # axisbox is set to the actual min and max of the values of the ticks
    # and determines the extent of the axis region of the plot
    if ao.tight
        axisbox = expand_box(databox, ao.xdatamargin, ao.ydatamargin)
    else
        axisbox = ifnotmissing(ao.axisbox, get_tick_extents(ticks))
    end


    
    # set window width/height based on axis limits
    # if asked to do so
    width, height = set_window_size_from_data(ao.width, ao.height, axisbox, margins(ao),
                                   ao.widthfromdata, ao.heightfromdata)

    ax = AxisMap(width, height, margins(ao), axisbox,
                 ao.axisequal, ao.yoriginatbottom)
  
    #    axis = Axis(wh..., ax, axisbox, ticks, ao.axisstyle,
    #                ao.yoriginatbottom, ao.windowbackgroundcolor,
    #                ao.drawbackground)

    axis = Axis(ax, axisbox, ticks, ao.axisstyle, ao.yoriginatbottom, ao.xticksatright, width, height,
                ao.drawbackground, ao.windowbackgroundcolor)
    return axis
end





function AxisDrawables.AxisDrawable(axis::Axis; fname = nothing)
    # The call to Drawable starts the interaction with Cairo
    dw = Drawable(axis.width, axis.height; fname)
    return AxisDrawable(axis, dw)
end

                                    
function AxisDrawables.AxisDrawable(p, ao::AxisOptions; fname = nothing)
    axis = Axis(p, ao)
    return AxisDrawable(axis; fname)
end
                                    
function AxisDrawables.AxisDrawable(ao::AxisOptions; fname = nothing)
    axis = Axis(ao)
    return AxisDrawable(axis; fname)
end
                
             



AxisDrawables.AxisDrawable(p; fname = nothing, kw...) = AxisDrawable(p, parse_axis_options(; kw...); fname)
AxisDrawables.AxisDrawable(; fname = nothing, kw...) = AxisDrawable(parse_axis_options(; kw...); fname)

DrawAxis.Axis(p::Vector{PointList}, ao::AxisOptions) = Axis(flat(p), ao)
DrawAxis.Axis(p; kw...) = Axis(p, parse_axis_options(; kw...))
DrawAxis.Axis(; kw...) = Axis(parse_axis_options(; kw...))




##############################################################################


function parse_axis_options(; kw...)
    ao = AxisOptions()
    setoptions!(ao, "", kw...)
    setoptions!(ao, "axisoptions_", kw...)
    setoptions!(ao.tickbox, "tickbox_", kw...)
    setoptions!(ao.axisbox, "axisbox_", kw...)
    setoptions!(ao.ticks, "ticks_", kw...)
    setoptions!(ao.axisstyle, "axisstyle_", kw...)
    return ao
end
    

##############################################################################

function set_window_size_from_data(width, height, b::Box,
                                   (lmargin, rmargin, tmargin, bmargin),
                                   widthfromdata, heightfromdata)
    if widthfromdata != 0
        width = (b.xmax - b.xmin) * widthfromdata + lmargin + rmargin
        width = Int(round(width))
    end
    if heightfromdata != 0
        height = (b.ymax - b.ymin) * heightfromdata + tmargin + bmargin
        height = Int(round(height))
    end
    return width, height
end

##############################################################################

  
# used when you don't have any data and want to ask
# for specific limits on the axis
#fit_box_around_data(p::Missing, box0::Box) = iffinite(box0, Box(0,1,0,1))


function fit_box_around_data(p::PointList, box0::Box)
    truncdata = remove_data_outside_box(p, box0)
    if length(truncdata.points) == 0
        return Box(0,1,0,1)
    end
    boxtmp = smallest_box_containing_data(truncdata)
    box1 = iffinite(box0, boxtmp)
end

# if x = [p1,p2,p3]  returns x
# if x = [ [p1,p2],[p3,p4,p5]] returns [p1,p2,p3,p4,p5]
#
# should work for arbitrary dimensional array
#flat_list_of_points(x::Vector{Point}) = x
#function flat_list_of_points(slist)
#    # nomissing is a list whoses elements are Vector{Point}
#    nomissing = Vector{Point}[series for series in skipmissing(slist)]
#    # flat is a Vector{Point}
#    flat = reduce(vcat, nomissing)
#end




##############################################################################
# utilities


margins(a) = (a.lmargin, a.rmargin, a.tmargin, a.bmargin)




##############################################################################
# keyword args

##############################################################################





end
