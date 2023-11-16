
module ColorBar

using ..PlotKitCairo: Gradient, Point, add_color_stop, destroy, linear_pattern, rect
using ..AxisDrawables: AxisDrawable
using ..DrawAxis: drawaxis, setclipbox

export colorbar, categoricalcolorbar

##############################################################################
# colorbar


function colorbar(g::Gradient; cmin = 0, cmax = 1, kw...)
    ad = AxisDrawable([Point(0,cmin), Point(1,cmax)]; width = 200,
                      axisstyle_drawxlabels = false,
                      axisstyle_ytickhorizontaloffset = -26,
                      yidealnumlabels = 6,
                      axisbox_ymin = cmin,
                      axisbox_ymax = cmax,
                      xticksatright = true, kw...)
    drawaxis(ad)
    setclipbox(ad)
    pat = linear_pattern(ad, Point(0,cmin), Point(0,cmax))
    for i =1:length(g.colors)
        add_color_stop(pat, g.stops[i], g.colors[i])
    end
    rect(ad, Point(0,cmin), Point(1,cmax-cmin); fillcolor = pat)
    destroy(pat)
    return ad
end

#
# divide the interval [0,1] into n colors
# with transition between color[i] and color[i+1]
# at values[i+1]
# values[1] = 0
# values[end] = 1
# length(values) = length(colors) + 1
#
# the axis ranges exactly from cmin to cmax
#
function categoricalcolorbar(colors, values; cmin = 0, cmax = 1, kw...)
    ad = AxisDrawable([Point(0,cmin), Point(1,cmax)]; width = 200,
                      axisstyle_drawxlabels = false,
                      axisstyle_ytickhorizontaloffset = -26,
                      yidealnumlabels = length(values)-1,
                      axisbox_ymin = cmin,
                      axisbox_ymax = cmax,
                      xticksatright = true, kw...)
    drawaxis(ad)
    setclipbox(ad)
    vmin = values[1]
    vmax = values[end]
    intx(v) = (1-v)*cmin + v*cmax
    for i = 1:length(colors)
        cstart = values[i]
        if i == length(colors)
            cend = 1
        else
            cend = values[i+1]
        end
        rect(ad, Point(0,intx(cstart)), Point(1, intx(cend)); fillcolor = colors[i])
    end
    return ad
end


end

