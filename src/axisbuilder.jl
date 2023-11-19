

module AxisBuilder

using ..PlotKitCairo: Drawable, Box, Point, Drawable, Color, inbox, expand_box, scale_box
using ..AxisDrawables: AxisDrawable, AxisDrawables
using ..DrawAxis: Axis, DrawAxis, AxisStyle
using ..MakeTicks: Ticks, get_tick_extents
using ..MakeAxisMap: AxisMap, @plotfns

export AxisOptions, PointList, allowed_kws, colorbar, input, setoptions!, smallest_box_containing_data


mutable struct PointList
    points::Vector{Point}
end

# input returns a vector of pointlists
input(data::Vector{Point}) = [PointList(data)]
input(data::Array{Vector{Point}}) = [PointList(p) for p in data[:]]


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
    ticks = ifnotmissingticks(ao.ticks, Ticks(tickbox,  ao.xidealnumlabels, ao.yidealnumlabels))

    # axisbox is set to the actual min and max of the values of the ticks
    # and determines the extent of the axis region of the plot
    axisbox = ifnotmissing(ao.axisbox, get_tick_extents(ticks))

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

flat(pl::PointList) = pl
flat(pl::Vector{PointList}) = PointList(reduce(vcat, a.points for a in pl))
  
# used when you don't have any data and want to ask
# for specific limits on the axis
#fit_box_around_data(p::Missing, box0::Box) = iffinite(box0, Box(0,1,0,1))


function fit_box_around_data(p::PointList, box0::Box)
    truncdata = remove_data_outside_box(p, box0)
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

remove_data_outside_box(pl::PointList, box::Box) = PointList(Point[a for a in pl.points if inbox(a, box)])

function smallest_box_containing_data(pl::PointList)
    xmin = minimum(a.x for a in pl.points)
    xmax = maximum(a.x for a in pl.points)
    ymin = minimum(a.y for a in pl.points)
    ymax = maximum(a.y for a in pl.points)
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

# For a type T defined using @kwdef, this function returns the fieldnames
# which can be sent as kw arguments to its constructor
# So you can call 
#
#  T(; allowed_kws(T, kw)...)
#
# when kw is supplied from the kwargs of a function call
#
allowed_kws(T, kw) = Dict(a => kw[a] for a in keys(kw) if a in fieldnames(T))

##############################################################################

getbox(a) = Box(a.xmin, a.xmax, a.ymin, a.ymax)




end
