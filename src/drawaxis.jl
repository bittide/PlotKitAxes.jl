
module DrawAxis

using Cairo
using ..PlotKitCairo: Box, Point, Color, Drawable, LineStyle, source, set_linestyle
using ..MakeAxisMap: @plotfns, AxisMap
using ..MakeTicks: Ticks

export Axis, AxisStyle, drawaxis, setclipbox

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
    fontcolor = Color(:black)
    drawxlabels = true
    drawylabels = true
    drawaxis = true
    drawvgridlines = true
    drawhgridlines = true
    title = ""
end

mutable struct Axis
    ax::AxisMap      # provides function mapping data coords to pixels
    box::Box         # extents of the axis in data coordinates
    ticks::Ticks
    as::AxisStyle
    yoriginatbottom
end


#    box::Box         # extents of the axis in data coordinates
function drawaxis(ctx::CairoContext, axismap, ticks, box, as::AxisStyle)
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
                text(ctx, Point(fx(xt), fy(ymin) + as.xtickverticaloffset),
                     as.fontsize, as.fontcolor, xtickstrings[i];
                     horizontal = "center")
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
                text(ctx, Point(fx(xmin) + as.ytickhorizontaloffset, fy(yt)),
                     as.fontsize, as.fontcolor, ytickstrings[i];
                     horizontal = "right", vertical = "center")
            end
        end
    end
    if as.drawbox
        Cairo.move_to(ctx, rfx(xmin)-0.5, rfy(ymax)-0.5)  #tl
        Cairo.line_to(ctx, rfx(xmin)-0.5, rfy(ymin)+0.5)  #bl
        Cairo.line_to(ctx, rfx(xmax)+0.5, rfy(ymin)+0.5)  #br
        Cairo.line_to(ctx, rfx(xmax)+0.5, rfy(ymax)-0.5)  #tr
        Cairo.close_path(ctx)
        set_linestyle(ctx, as.edgelinestyle)
        Cairo.stroke(ctx)
    end
    text(ctx, Point(fx((xmin+xmax)/2), fy(ymax) + 15), as.fontsize, as.fontcolor, as.title;
         horizontal = "center")
    
end


drawaxis(ctx::CairoContext, axis::Axis) = drawaxis(ctx, axis.ax, axis.ticks, axis.box, axis.as)
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
