
plotpath(x) = joinpath(ENV["HOME"], "plots/", x)

function main()
    @testset "PlotKitAxes.DrawAxis" begin
        @test main1()
        @test main2()
        @test main3()
        @test main4()
    end
end

function main1()
    width = 800
    height = 600
    fname = plotpath("test_drawaxis1.pdf")

    margins = (80,80,80,80)  # l,r,t,b
    yoriginatbottom = true
    xticksatright = false
    axisequal = false
    box = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, box, axisequal, yoriginatbottom)
    ticks = Ticks(box, 10, 10)
    as = AxisStyle()

    # drawing
    dw = Drawable(width, height; fname)
    drawaxis(dw.ctx, axismap, ticks, box, as, yoriginatbottom, xticksatright)
    close(dw)
    return true
end

function main2()
    width = 800
    height = 600
    fname = plotpath("test_drawaxis2.pdf")

    margins = (80,80,80,80)  # l,r,t,b
    yoriginatbottom = true
    xticksatright = false
    axisequal = false
    drawbackground = true
    windowbackgroundcolor = Color(:white)
    box = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, box, axisequal, yoriginatbottom)
    ticks = Ticks(box, 10, 10)
    as = AxisStyle()
    axis = Axis(axismap, box, ticks, as, yoriginatbottom, xticksatright,
                width, height, drawbackground, windowbackgroundcolor)

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
    xticksatright = false
    drawbackground = true
    windowbackgroundcolor = Color(:white)
    axis = Axis(axismap, box, ticks, as, yoriginatbottom, xticksatright,
                width, height, drawbackground, windowbackgroundcolor)
    dw = Drawable(width, height)
    rect(dw.ctx, Point(0,0), Point(width, height); fillcolor =  windowbackgroundcolor)
    drawaxis(dw.ctx, axis)
    setclipbox(dw.ctx, axismap, box)
    line(dw.ctx, axismap.(Point.(zip(x, y))); linestyle=LineStyle(Color(:blue), 1))
    save(dw, plotpath("test_drawaxis3.pdf"))
    return true
end

# doing it yourself
function main4()
    x = 0:0.1:10
    y = x.*x/10

    desired_range = Box(xmin = 0, xmax = 10, ymin = 0, ymax = 30)
    ticks = Ticks(desired_range, 10, 10)
    range = get_tick_extents(ticks)
    width = 800
    height = 600
    margins = (80, 80, 80, 80)
    yoriginatbottom = true
    xticksatright = false

    windowbackgroundcolor = Color(:white)
    as = AxisStyle()
    ax = AxisMap(width, height, margins, range, false, true)

    d = Drawable(width, height)
    rect(d, Point(0,0), Point(width, height); fillcolor =  windowbackgroundcolor)
    drawaxis(d, ax, ticks, range, as, yoriginatbottom, xticksatright)
    setclipbox(d, ax, range)
    line(d,  ax.(Point.(zip(x, y))); linestyle=LineStyle(Color(:black), 1))

    save(d, plotpath("test_drawaxis4.pdf"))
    return true
end
