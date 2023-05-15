
plotpath(x) = joinpath(ENV["HOME"], "/tmp/", x)

function main()
    @testset "PlotKitAxes.DrawAxis" begin
        @test main1()
        @test main2()
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

