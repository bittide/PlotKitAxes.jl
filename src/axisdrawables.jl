
module AxisDrawables

using Cairo
using ..DrawAxis
using ..MakeTicks: Ticks
using ..MakeAxisMap: AxisMap, @plotfns
using ..PlotKitCairo: Point, Drawable, Box, PlotKitCairo, rect

#export Axis

#
# We use Axis to draw the axis, in addition to the axisstyle.
# Axis also contains information about the window:
#
#   width, height, windowbackgroundcolor, drawbackground,
#
# and information about the axis which is not style
#
#   ticks, box, yoriginatbottom
#
# and the AxisStyle object "as". Note that the AxisStyle object
# is provided by the user, and unchanged, but the ticks, and box
# are computed by the Axis constructor.
#
# yoriginatbottom comes from the AxisOptions, and affects
# both the axis drawing and the axismap.
#
# All of this is necessary to draw the axis.
#
# We use AxisMap to draw the graph on the axis.
#



mutable struct AxisDrawable 
    dw::Drawable
    axis::Axis
    drawbackground
    backgroundcolor
end


# also draw background
function PlotKitCairo.draw(axis::Axis)
    if axis.drawbackground
        rect(axis.dw, Point(0,0), Point(axis.dw.width, axis.dw.height);
             fillcolor=axis.windowbackgroundcolor)
    end
    drawaxis(axis.dw.ctx, axis.ax, axis.ticks, axis.box, axis.as)
end


# This should be factored differently
function setclipbox(ctx::CairoContext, axis::Axis)
    @plotfns ax
    box = axis.box
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    Cairo.rectangle(ctx, rfx(xmin), rfy(ymin), rfx(xmax)-rfx(xmin),
                    rfy(ymax)-rfy(ymin))
    Cairo.clip(ctx)
    Cairo.new_path(ctx)
end
setclipbox(dw::Drawable, args...) = setclipbox(dw.ctx, args...)


end
