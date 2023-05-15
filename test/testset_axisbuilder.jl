

plotpath(x) = joinpath(ENV["HOME"], "/plots/", x)

function main()
    @testset "PlotKitAxes.AxisBuilder" begin
        @test main1()
        @test main2()
        @test main3()
        @test main4()
    end
end

pzip(a,b) = Point.(zip(a,b))
function plot(x, y; fname = nothing)
    data = pzip(x,y)
    ad = AxisDrawable(data; fname )
    drawaxis(ad)
    setclipbox(ad)
    line(ad, data; linestyle = LineStyle(Color(:red),1))
    return ad
end

# line plot
function main1()
    width = 800
    height = 600
    fname = plotpath("test_axisbuilder1.pdf")
    data = [Point(x, x.*x/10) for x = 0:0.1:10]

    # drawing
    ad = AxisDrawable(data; fname )
    drawaxis(ad)
    line(ad, data; linestyle = LineStyle(Color(:red),1))
    close(ad)
    return true
end


# just the basic plot
function main2()
    fname = plotpath("test_axisbuilder2.pdf")
    data = [Point(x, x.*x) for x = -0.1:0.1:2.85]
    ad = AxisDrawable(data; fname )
    drawaxis(ad)
    for p in data
        circle(ad, p, 2; fillcolor = 0.5*Color(:white))
    end
    close(ad)
    return true
end


# doing it yourself
function main3()
    x = 0:0.1:10
    y = x.*x/10

    xt = PlotKitAxes.MakeTicks.best_ticks(minimum(x), maximum(x), 10)
    yt = PlotKitAxes.MakeTicks.best_ticks(minimum(y), maximum(y), 10)
    xl = PlotKitAxes.MakeTicks.best_labels(xt)
    yl = PlotKitAxes.MakeTicks.best_labels(yt)
    ticks = Ticks(xt, xl, yt, yl)

    box = Box(minimum(xt), maximum(xt), minimum(yt), maximum(yt))
    width = 800
    height = 600
    margins = (80, 80, 80, 80)
    windowbackgroundcolor = Color(:white)
    as = AxisStyle()
    ax = AxisMap(width, height, margins, box, false, true)
    fname = plotpath("test_axisbuilder3.pdf")
    dw = Drawable(width, height; fname)
    rect(dw, Point(0,0), Point(width, height); fillcolor =  windowbackgroundcolor)
    drawaxis(dw, ax, ticks, box, as)
    setclipbox(dw, ax, box)
    line(dw, ax.(Point.(zip(x, y))); linestyle=LineStyle(Color(:blue), 1))
    close(dw)
    return true
end

# line plot
function main4()
    x1 = -0.1:0.1:1.3
    y1 = x1.*x1
    fname = plotpath("test_axisbuilder4.pdf")
    ad = plot(x1, y1; fname)
    close(ad)
    return true
end

# two plots, one above the other
function main5()
    x1 = -0.1:0.1:1.3
    y1 = x1.*x1
    d1 = plot(x1, y1; height=400)

    x2 = -0.2:0.05:1.4
    y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)
    d2 = plot(x2, y2; height=320, tmargin=0)

    
    qsave(vbox(d1, d2), "basic4.pdf")
end
