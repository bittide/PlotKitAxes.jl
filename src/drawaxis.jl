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

module DrawAxis

using Cairo
using PlotKitCairo: Box, Point, Color, Drawable, LineStyle, source, set_linestyle

using ..MakeAxisMap: @plotfns, AxisMap
using ..MakeTicks: Ticks

export Axis, AxisStyle, drawaxis, setclipbox, drawaxisbox

##############################################################################

#
# AxisStyle specifies how to draw the axis. It
# is set by the user
#
Base.@kwdef mutable struct AxisStyle
    drawbox = false
    edgelinestyle = LineStyle(Color(:black), 2)
    drawaxisbackground = true
    xtickverticaloffset = 16
    ytickhorizontaloffset = -8
    backgroundcolor = Color(:bluegray)
    gridlinestyle = LineStyle(Color(:white), 1)
    fontsize = 13
    fontname = "Sans"
    fontcolor = Color(:black)
    drawxlabels = true
    drawylabels = true
    drawaxis = true
    drawvgridlines = true
    drawhgridlines = true
    title = ""
    titlefontsize = 13
    titlefontname = "Sans"
    titlefontcolor = Color(:black)
    titlevoffset = 15
end

mutable struct Axis
    ax::AxisMap      # provides function mapping data coords to pixels
    box::Box         # extents of the axis in data coordinates
    ticks::Ticks
    as::AxisStyle
    yoriginatbottom
    xticksatright
    width
    height
    drawwindowbackground
    windowbackgroundcolor
end


#    box::Box         # extents of the axis in data coordinates
function drawaxis(ctx::CairoContext, axismap, ticks, box, as::AxisStyle, yoriginatbottom, xticksatright)
    if !as.drawaxis
        return
    end
    xticks = ticks.xticks
    xtickstrings = ticks.xtickstrings
    yticks = ticks.yticks
    ytickstrings = ticks.ytickstrings
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    @plotfns(axismap)
    if as.drawaxisbackground
        Cairo.rectangle(ctx, rfx(xmin), rfy(ymin), rfx(xmax)-rfx(xmin),
                        rfy(ymax)-rfy(ymin))
        source(ctx, as.backgroundcolor)
        Cairo.fill(ctx)
    end
    Cairo.set_line_width(ctx, 1)
    for i=1:length(xticks)
        xt = xticks[i]
        if as.drawvgridlines
            if xt>xmin && xt<xmax
                Cairo.move_to(ctx, rfx(xt)-0.5, rfy(ymax))  
                Cairo.line_to(ctx, rfx(xt)-0.5, rfy(ymin))
                set_linestyle(ctx, as.gridlinestyle)
                Cairo.stroke(ctx)
            end
        end
        if xt>=xmin && xt<=xmax
            if as.drawxlabels
                ypos = fy(ymin) + as.xtickverticaloffset
                if !yoriginatbottom
                    ypos = fy(ymin) - as.xtickverticaloffset + 0.7 * as.fontsize
                end
                text(ctx, Point(fx(xt), ypos),
                     as.fontsize, as.fontcolor, xtickstrings[i];
                     fname = as.fontname, horizontal = "center")
            end
        end
    end
    for i=1:length(yticks)
        yt = yticks[i]
        if as.drawhgridlines
            if yt>ymin && yt<ymax
                Cairo.move_to(ctx, rfx(xmin), rfy(yt)-0.5) 
                Cairo.line_to(ctx, rfx(xmax), rfy(yt)-0.5)
                set_linestyle(ctx, as.gridlinestyle)
                Cairo.stroke(ctx)
            end
        end
        if yt>=ymin && yt<=ymax
            if as.drawylabels
                xpos = fx(xmin) + as.ytickhorizontaloffset
                if xticksatright
                    xpos = fx(xmax) - as.ytickhorizontaloffset
                end
                             
                text(ctx, Point(xpos, fy(yt)),
                     as.fontsize, as.fontcolor, ytickstrings[i];
                     fname = as.fontname, horizontal = "right", vertical = "center")
            end
        end
    end
    if as.drawbox
        drawaxisbox(ctx, axismap, box, as)
    end
    text(ctx, Point(fx((xmin+xmax)/2), fy(ymax) + as.titlevoffset), as.titlefontsize, as.titlefontcolor, as.title;
         fname = as.titlefontname, horizontal = "center")
    
end

function drawaxisbox(ctx::CairoContext, axismap, box, as::AxisStyle)
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    @plotfns(axismap)
    Cairo.move_to(ctx, rfx(xmin)-0.5, rfy(ymax)-0.5)  #tl
    Cairo.line_to(ctx, rfx(xmin)-0.5, rfy(ymin)+0.5)  #bl
    Cairo.line_to(ctx, rfx(xmax)+0.5, rfy(ymin)+0.5)  #br
    Cairo.line_to(ctx, rfx(xmax)+0.5, rfy(ymax)-0.5)  #tr
    Cairo.close_path(ctx)
    set_linestyle(ctx, as.edgelinestyle)
    Cairo.stroke(ctx)
end


drawaxisbox(ctx::CairoContext, axis::Axis) = drawaxisbox(ctx, axis.ax, axis.box, axis.as)
drawaxisbox(dw::Drawable, args...) = drawaxisbox(dw.ctx, args...)

drawaxis(ctx::CairoContext, axis::Axis) = drawaxis(ctx, axis.ax, axis.ticks, axis.box, axis.as, axis.yoriginatbottom,
                                                   axis.xticksatright)
drawaxis(dw::Drawable, args...) = drawaxis(dw.ctx, args...)

function setclipbox(ctx::CairoContext, ax::AxisMap, box::Box)
    @plotfns ax
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    Cairo.rectangle(ctx, rfx(xmin), rfy(ymin), rfx(xmax)-rfx(xmin), rfy(ymax)-rfy(ymin))
    Cairo.clip(ctx)
    Cairo.new_path(ctx)
end
setclipbox(dw::Drawable, ax::AxisMap, box::Box) = setclipbox(dw.ctx, ax, box)

end
