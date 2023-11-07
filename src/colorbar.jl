
module ColorBar

using ..PlotKitCairo: Gradient, Point, add_color_stop, destroy, linear_pattern, rect
using ..AxisDrawables: AxisDrawable
using ..DrawAxis: drawaxis, setclipbox

export colorbar

##############################################################################
# colorbar


function colorbar(g::Gradient; cmin = 0, cmax = 1, kw...)
    ad = AxisDrawable([Point(0,cmin), Point(1,cmax)]; width = 200,
                      axisstyle_drawxlabels = false,
                      axisstyle_ytickhorizontaloffset = -26,
                      yidealnumlabels = 6,
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


end

