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

module MakeAxisMap

using Cairo
using PlotKitCairo: Box, Point
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

(ax::AxisMap)(p::Point) = ax.f(p)
(ax::AxisMap)(plist::Array{Point}) = ax.f.(plist)



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

