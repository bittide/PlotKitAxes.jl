
plotpath(x) = joinpath(ENV["HOME"], "plots/", x)

function main()
    @testset "PlotKitAxes.AxisDrawables" begin
        @test main1()
    end
end

function main1()
    width = 800
    height = 600
    fname = plotpath("test_axisdrawable1.pdf")

    margins = (80,80,80,80)  # l,r,t,b
    yoriginatbottom = true
    xticksatright = false
    axisequal = false
    drawbackground = true
    windowbackgroundcolor = Color(0.8, 0.8, 1)
    box = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, box, axisequal, yoriginatbottom)
    ticks = Ticks(box, 10, 10)
    as = AxisStyle()
    axis = Axis(axismap, box, ticks, as, yoriginatbottom, xticksatright, width, height,
                drawbackground, windowbackgroundcolor)

    # drawing
    dw = Drawable(width, height; fname)
    ad = AxisDrawable(axis, dw)
    drawaxis(ad)
    line(ad, Point(0.1,0.2), Point(0.3,0.4); linestyle = LineStyle(Color(:red),1))
    close(ad)
    return true
end

