
plotpath(x) = joinpath(ENV["HOME"], "plots/", x)

function main()
    @testset "PlotKitAxes.DrawAxis" begin
        @test main1()
        @test main2()
        @test main3()
    end
end

function main1()
    width = 800
    height = 600
    fname = plotpath("test_drawaxis1.pdf")

    margins = (80,80,80,80)  # l,r,t,b
    yoriginatbottom = true
    axisequal = false
    box = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, box, axisequal, yoriginatbottom)
    ticks = Ticks(box, 10, 10)
    as = AxisStyle()

    # drawing
    dw = Drawable(width, height; fname)
    drawaxis(dw.ctx, axismap, ticks, box, as)
    close(dw)
    return true
end

function main2()
    width = 800
    height = 600
    fname = plotpath("test_drawaxis2.pdf")

    margins = (80,80,80,80)  # l,r,t,b
    yoriginatbottom = true
    axisequal = false
    box = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, box, axisequal, yoriginatbottom)
    ticks = Ticks(box, 10, 10)
    as = AxisStyle()
    axis = Axis(axismap, box, ticks, as, yoriginatbottom)

    # drawing
    dw = Drawable(width, height; fname)
    drawaxis(dw.ctx, axis)
    close(dw)
    return true
end


# doing it yourself
function main3()
    x = 0:0.1:10
    y = x.*x/10
    xt = best_ticks(minimum(x), maximum(x), 10)
    yt = best_ticks(minimum(y), maximum(y), 10)
    xl = best_labels(xt)
    yl = best_labels(yt)
    ticks = Ticks(xt, xl, yt, yl)
    box = Box(minimum(xt), maximum(xt), minimum(yt), maximum(yt))
    width = 800
    height = 600
    margins = (80, 80, 80, 80)
    windowbackgroundcolor = Color(:white)
    as = AxisStyle()
    axismap = AxisMap(width, height, margins, box, false, true)
    yoriginatbottom = true
    axis = Axis(axismap, box, ticks, as, yoriginatbottom)
    dw = Drawable(width, height)
    rect(dw.ctx, Point(0,0), Point(width, height); fillcolor =  windowbackgroundcolor)
    drawaxis(dw.ctx, axis)
    setclipbox(dw.ctx, axismap, box)
    line(dw.ctx, axismap.(Point.(zip(x, y))); linestyle=LineStyle(Color(:blue), 1))
    save(dw, plotpath("test_drawaxis3.pdf"))
    return true
end
