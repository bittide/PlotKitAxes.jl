

module AxisBuilder

using ..PlotKitCairo: Drawable, Box, Point, Drawable, Color, inbox, expand_box, scale_box
using ..AxisDrawables: AxisDrawable, AxisDrawables
using ..DrawAxis: Axis, DrawAxis, AxisStyle
using ..MakeTicks: Ticks, get_tick_extents
using ..MakeAxisMap: AxisMap, @plotfns

export setoptions!
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
    axisequal = false
    windowbackgroundcolor = Color(:white)
    drawbackground = true
    drawaxis = true
    ticks = Ticks()
    axisstyle = AxisStyle()
    tickbox = Box()
    axisbox = Box()
end

##############################################################################

function AxisDrawables.AxisDrawable(p, ao::AxisOptions; fname = nothing)
    
    ignore_data_outside_this_box = getbox(ao)
    
    # tickbox is set to a box that contains the data
    # so if ignore_data_outside_this_box specifies limits on x,
    # then the data is used to determine limits on y
    # and these limits go into tickbox
    boxtmp = fit_box_around_data(p, ignore_data_outside_this_box)
    tickbox = ifnotmissing(ao.tickbox,
                           scale_box(expand_box(boxtmp, ao.xdatamargin, ao.ydatamargin),
                                     ao.xwidenfactor, ao.ywidenfactor))

    # tickbox used to define the minimum area which the ticks
    # are guaranteed to contain
    # Ticks is a set of ticks chosen to be pretty, and to contain tickbox
    ticks = ifnotmissingticks(ao.ticks, Ticks(tickbox,  ao.xidealnumlabels, ao.yidealnumlabels))

    # axisbox is set to the actual min and max of the values of the ticks
    # and determines the extent of the axis region of the plot
    axisbox = ifnotmissing(ao.axisbox, get_tick_extents(ticks))

    # set window width/height based on axis limits
    # if asked to do so
    wh = set_window_size_from_data(ao.width, ao.height, axisbox, margins(ao),
                                   ao.widthfromdata, ao.heightfromdata)

    ax = AxisMap(wh..., margins(ao), axisbox,
                 ao.axisequal, ao.yoriginatbottom)
  
    #    axis = Axis(wh..., ax, axisbox, ticks, ao.axisstyle,
    #                ao.yoriginatbottom, ao.windowbackgroundcolor,
    #                ao.drawbackground)

    axis = Axis(ax, axisbox, ticks, ao.axisstyle, ao.yoriginatbottom)
    dw = Drawable(wh...; fname)
    return AxisDrawable(axis, dw; drawbackground = ao.drawbackground,
                        backgroundcolor = ao.windowbackgroundcolor)

end

AxisDrawables.AxisDrawable(ao::AxisOptions; fname = nothing) = AxisDrawable(missing, ao; fname)
AxisDrawables.AxisDrawable(p; fname = nothing, kw...) = AxisDrawable(p, parse_axis_options(; kw...); fname)
AxisDrawables.AxisDrawable(; fname = nothing, kw...) = AxisDrawable(missing; kw..., fname)


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
    end
    if heightfromdata != 0
        height = (b.ymax - b.ymin) * heightfromdata + tmargin + bmargin
    end
    return width, height
end

##############################################################################

  
# used when you don't have any data and want to ask
# for specific limits on the axis
fit_box_around_data(p::Missing, box0::Box) = iffinite(box0, Box(0,1,0,1))


function fit_box_around_data(p, box0::Box)
    flattened_data = flat_list_of_points(p)
    truncdata = remove_data_outside_box(flattened_data, box0)
    boxtmp = smallest_box_containing_data(truncdata)
    box1 = iffinite(box0, boxtmp)
end

# if x = [p1,p2,p3]  returns x
# if x = [ [p1,p2],[p3,p4,p5]] returns [p1,p2,p3,p4,p5]
#
# should work for arbitrary dimensional array
flat_list_of_points(x::Vector{Point}) = x
function flat_list_of_points(slist)
    # nomissing is a list whoses elements are Vector{Point}
    nomissing = Vector{Point}[series for series in skipmissing(slist)]
    # flat is a Vector{Point}
    flat = reduce(vcat, nomissing)
end
function iffinite(r::Number, d::Number)
    if isfinite(r)
        return r
    end
    return d
end

# if requested limits are finite, use them
function iffinite(a::Box, b::Box)
    xmin = iffinite(a.xmin, b.xmin)
    xmax = iffinite(a.xmax, b.xmax)
    ymin = iffinite(a.ymin, b.ymin)
    ymax = iffinite(a.ymax, b.ymax)
    return Box(xmin, xmax, ymin, ymax)
end

remove_data_outside_box(plist, b::Box) = Point[p for p in plist if inbox(p, b)]

function smallest_box_containing_data(plist)
    xmin = minimum(a.x for a in plist)
    xmax = maximum(a.x for a in plist)
    ymin = minimum(a.y for a in plist)
    ymax = maximum(a.y for a in plist)
    return Box(xmin, xmax, ymin, ymax)
end


##############################################################################
# utilities


ifnotmissing(x::Missing, y) = y
ifnotmissing(x, y) = x

function ifnotmissing(a::Box, b::Box)
    return Box(ifnotmissing(a.xmin, b.xmin),
               ifnotmissing(a.xmax, b.xmax),
               ifnotmissing(a.ymin, b.ymin),
               ifnotmissing(a.ymax, b.ymax))
end


function ifnotmissingticks(a::Ticks, b::Ticks)
    return Ticks(ifnotmissing(a.xticks, b.xticks),
                 ifnotmissing(a.xtickstrings, b.xtickstrings),
                 ifnotmissing(a.yticks, b.yticks),
                 ifnotmissing(a.ytickstrings, b.ytickstrings))
end

margins(a) = (a.lmargin, a.rmargin, a.tmargin, a.bmargin)




##############################################################################
# keyword args

function symsplit(s::Symbol, a::String)
    n = length(a)
    st = string(s)
    if length(st) > n && st[1:length(a)] == a
        return true, Symbol(st[length(a)+1:end])
    end
    return false, :nosuchsymbol
end

function setoptions!(d, prefix, kwargs...)
    for (key, value) in kwargs
        match, tail = symsplit(key, prefix)
        if match && tail in fieldnames(typeof(d))
            setfield!(d, tail, value)
        end
    end
end

##############################################################################

getbox(a) = Box(a.xmin, a.xmax, a.ymin, a.ymax)

##############################################################################



end
