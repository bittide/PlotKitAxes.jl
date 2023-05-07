
module MakeAxisMap

using ..PlotKitCairo: Box, Point
export  @plotfns, AxisMap

# should be axfns
macro plotfns(ax)
    return esc(quote
               rfx = x -> round($ax.fx(x))
               rfy = y -> round($ax.fy(y))
               rf = p -> (rfx(p[1]), rfy(p[2]))
               fx = x -> $ax.fx(x)
               fy = y -> $ax.fy(y)
               f = p::Point -> Point(fx(p.x), fy(p.y))
    end)
end

# AxisMap and its constructor
struct AxisMap
    fx
    fy
    f
    fxinv
    fyinv
    finv
end



# construct f mapping data coords to window coords
function onecoordfunction(width, leftmargin, rightmargin, xmin, xmax)
    t = (width-leftmargin-rightmargin)/(xmax-xmin)
    cx = leftmargin -t*xmin
    return t, cx
end

# b is the box with the actual min and max of the data region 
# and determines the extent of the axis region of the plot
function AxisMap(w, h, (lmargin, rmargin, tmargin, bmargin), b::Box,
                           axisequal, yoriginatbottom)
    if axisequal
        # aspect ratios
        ar_data = (b.xmax - b.xmin) / (b.ymax - b.ymin)
        ar_window = (w - lmargin - rmargin)/(h - tmargin - bmargin)
        if ar_data > ar_window
            # letterbox format
            # leave axis width as default, and compute height of axis for
            # equal aspect ratio
            axiswidth = w - lmargin - rmargin
            axisheight = axiswidth / ar_data
            tmargin = (h - axisheight)/2
            bmargin = tmargin
        else
            # vertical letterbox
            axisheight = h - tmargin - bmargin
            axiswidth = axisheight * ar_data
            lmargin = (w - axiswidth)/2
            rmargin = lmargin
        end
    end
    tx, cx = onecoordfunction(w, lmargin, rmargin, b.xmin, b.xmax)
    ty, cy = onecoordfunction(h, bmargin, tmargin, b.ymin, b.ymax)
    if yoriginatbottom
        ty = -ty
        cy = h - cy
    end
    qfx = x -> tx * x + cx
    qfy = y -> ty * y + cy
    qfxinv = x -> (x - cx)/tx
    qfyinv = y -> (y - cy)/ty
    qf =  p::Point -> Point(qfx(p.x), qfy(p.y))
    qfinv =  p::Point -> Point(qfxinv(p.x), qfyinv(p.y))
    return AxisMap(qfx, qfy, qf, qfxinv, qfyinv, qfinv)
end

##############################################################################


end

