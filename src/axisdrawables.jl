
module AxisDrawables

using Cairo
using ..DrawAxis: Axis, drawaxis, DrawAxis
using ..MakeTicks: Ticks
using ..MakeAxisMap: AxisMap, @plotfns
using ..PlotKitCairo: Color, Point, Drawable, Box, PlotKitCairo, rect, ImageDrawable, PDFDrawable, SVGDrawable, RecorderDrawable

export AxisDrawable

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

abstract type AxisDrawable <: Drawable end

mutable struct AxisImageDrawable <: AxisDrawable
    surface
    ctx
    width
    height
    fname
    axis::Axis
    drawbackground
    backgroundcolor
end

mutable struct AxisPDFDrawable <: AxisDrawable
    surface
    ctx
    width
    height
    fname
    axis::Axis
    drawbackground
    backgroundcolor
end

mutable struct AxisSVGDrawable <: AxisDrawable
    surface
    ctx
    width
    height
    fname
    axis::Axis
    drawbackground
    backgroundcolor
end

mutable struct AxisRecorderDrawable <: AxisDrawable
    surface
    ctx
    width
    height
    axis::Axis
    drawbackground
    backgroundcolor
end

AxisDrawable(axis::Axis, dw::ImageDrawable) = AxisImageDrawable(dw.surface, dw.ctx, dw.width, dw.height, dw.fname, axis, true, Color(:white))
AxisDrawable(axis::Axis, dw::PDFDrawable) = AxisPDFDrawable(dw.surface, dw.ctx, dw.width, dw.height, dw.fname, axis, true, Color(:white))
AxisDrawable(axis::Axis, dw::SVGDrawable) = AxisSVGDrawable(dw.surface, dw.ctx, dw.width, dw.height, dw.fname, axis, true, Color(:white))
AxisDrawable(axis::Axis, dw::RecorderDrawable) = AxisRecorderDrawable(dw.surface, dw.ctx, dw.width, dw.height, dw.fname, axis, true, Color(:white))

# close has different behavior for ImageDrawable vs other Drawables
ImageDrawable(dw::AxisImageDrawable) = ImageDrawable(dw.surface, dw.ctx, dw.width, dw.height, dw.fname)
PlotKitCairo.close(dw::AxisImageDrawable) = PlotKitCairo.close(ImageDrawable(dw))

# paint and save only apply to RecorderDrawables
PlotKitCairo.paint(ctx::CairoContext, r::AxisRecorderDrawable, args...) = PlotKitCairo.paint(ctx, r, args...)
PlotKitCairo.save(r::AxisRecorderDrawable, args...) = PlotKitCairo.save(r, args...)


# also draw background
function DrawAxis.drawaxis(ad::AxisDrawable)
    if ad.drawbackground
        rect(ad.ctx, Point(0,0), Point(ad.width, ad.height); fillcolor = ad.backgroundcolor)
    end
    drawaxis(ad.ctx, ad.axis)
end


# This should be factored differently
function setclipbox(ad::AxisDrawable)
    @plotfns ad.axis.ax
    box = ad.axis.box
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    Cairo.rectangle(ad.ctx, rfx(xmin), rfy(ymin), rfx(xmax)-rfx(xmin), rfy(ymax)-rfy(ymin))
    Cairo.clip(ad.ctx)
    Cairo.new_path(ad.ctx)
end

##############################################################################
# drawing functions


# TODO: circle radius shouldbe in axis coords too? What about non-uniform x,y scaling


for f in (:line, :circle, :text)
    @eval function PlotKitCairo.$f(ad::AxisDrawable, p, args...; kwargs...)
        PlotKitCairo.$f(ad.ctx, ad.axis.ax(p), args...; kwargs...)
    end
end


# for functions with two arguments of type Point
for f in (:line,)
    @eval function PlotKitCairo.$f(ad::AxisDrawable, p::Point, q::Point, args...; kwargs...)
        PlotKitCairo.$f(ad.ctx, ad.axis.ax(p), ad.axis.ax(q), args...; kwargs...)
    end
end


# for functions with four arguments of type Point
for f in (:curve,)
    @eval function PlotKitCairo.$f(ad::AxisDrawable, p, q, r, s, args...; kwargs...)
        PlotKitCairo.$f(ad.ctx, ad.axis.ax(p), ad.axis.ax(q), ad.axis.ax(r), ad.axis.ax(s), args...; kwargs...)
    end
end


end
