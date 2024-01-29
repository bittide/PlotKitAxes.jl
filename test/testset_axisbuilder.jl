

plotpath(x) = joinpath(ENV["HOME"], "plots/", x)

function main()
    @testset "PlotKitAxes.AxisBuilder" begin
        @test main1()
        @test main2()
        @test main3()
        @test main4()
        @test main5()
        @test main6()
        @test main7()
        @test main8()
        @test main9()
        @test main10()
        @test main11()
        @test main12()
        @test main13()
        @test main14()
        @test main15()
        @test main16()
        @test main17()
        @test main18()
    end
end
getoptions(;kw...) = kw
pzip(a,b) = Point.(zip(a,b))
plot(x, y; kw...) = plot(pzip(x,y); kw...)

function plot(data; kw...)
    ad = AxisDrawable(PointList(data); kw... )
    drawaxis(ad)
    setclipbox(ad)
    line(ad, data; linestyle = LineStyle(Color(:red),1))
    return ad
end

# line plot
function main1()
    println("main1")
    
    width = 800
    height = 600
    fname = plotpath("test_axisbuilder1.pdf")
    data = [Point(x, x.*x/10) for x = 0:0.1:10]

    # drawing
    ad = AxisDrawable(PointList(data); fname )
    drawaxis(ad)
    line(ad, data; linestyle = LineStyle(Color(:red),1))
    close(ad)
    return true
end


# just the basic plot
function main2()
    println("main2")
    
    fname = plotpath("test_axisbuilder2.pdf")
    data = [Point(x, x.*x) for x = -0.1:0.1:2.85]
    ad = AxisDrawable(PointList(data); fname )
    drawaxis(ad)
    for p in data
        circle(ad, p, 2; fillcolor = 0.5*Color(:white))
    end
    close(ad)
    return true
end


# doing it yourself
function main3()
    println("main3")
    x = 0:0.1:10
    y = x.*x/10

    xt = MakeTicks.best_ticks(minimum(x), maximum(x), 10)
    yt = MakeTicks.best_ticks(minimum(y), maximum(y), 10)
    xl = MakeTicks.best_labels(xt)
    yl = MakeTicks.best_labels(yt)
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
    drawaxis(dw, ax, ticks, box, as, true, false)
    setclipbox(dw, ax, box)
    line(dw, ax.(Point.(zip(x, y))); linestyle=LineStyle(Color(:blue), 1))
    close(dw)
    return true
end

# line plot
function main4()
    println("main4")
    x1 = -0.1:0.1:1.3
    y1 = x1.*x1
    fname = plotpath("test_axisbuilder4.pdf")
    ad = plot(x1, y1; fname)
    close(ad)
    return true
end

# basic two plots on same graph
function main5()
    println("main5")
    x1 = -0.1:0.1:1.8
    y1 = x1.*x1
    x2 = -0.2:0.05:1.4
    y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)

    ad = AxisDrawable([PointList(pzip(x1, y1)); PointList(pzip(x2, y2))])
    drawaxis(ad)
    setclipbox(ad)
    line(ad, pzip(x1, y1); linestyle = LineStyle(Color(:red),1))
    line(ad, pzip(x2, y2); linestyle = LineStyle(Color(:blue),1))
    save(ad, plotpath("test_axisbuilder5.pdf"))
    return true
end



# two plots, one above the other
function main6()
    println("main6")
    x1 = -0.1:0.1:1.8
    y1 = x1.*x1
    d1 = plot(x1, y1; height=400)

    x2 = -0.2:0.05:1.4
    y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)
    d2 = plot(x2, y2; height=320, tmargin=0)
    
    save(vbox(d1, d2), plotpath("test_axisbuilder6.pdf"))
    return true
end


# overlays on basic plot
function main7()
    println("main7")
    x = -0.1:0.1:1.3
    y = x.*x
    d = plot(x,y)

    line(d, Point(0, 0), Point(1, 1); linestyle = LineStyle( Color(:black), 2))
    line(d.ctx, Point(0, 0), Point(400, 300); linestyle = LineStyle( Color(:blue), 2))
    save(d, plotpath("test_axisbuilder7.pdf"))
    return true
end

# many subplots
function main8()
    println("main8")
    fns = [sin, cos, exp, tan, sec, sinc]
    x = collect(-1:0.01:1)
    fs = [ plot(x, a.(x)) for a in fns ]
    save(hvbox(stacked(fs, 3)), plotpath("test_axisbuilder8.pdf"))
    return true
end


# set marker styles
function main9()
    println("main9")
    x = -0.3:0.1:1.3
    y = x.*x
    data = pzip(x,y)
    ad = AxisDrawable(PointList(data))
    drawaxis(ad)
    setclipbox(ad)
    line(ad, data; linestyle = LineStyle(Color(:blue),2))
    for p in data
        circle(ad, p, 10; scaletype = :none, linestyle=LineStyle(Color(:red),2),
               fillcolor = Color(:cyan))
    end
    save(ad, plotpath("test_axisbuilder9.pdf"))
    return true
end

# change the axis style
function main10()
    println("main10")
    data = Point[(x, x*x) for x in -0.1:0.01:1.85]
    opts = getoptions(; axisstyle_edgelinestyle = LineStyle(0.5 * Color(:white), 2),
                      axisstyle_gridlinestyle = LineStyle(Color(0.5,0.5,0.7), 1),
                      axisstyle_backgroundcolor = Color(:white),
                      axisstyle_drawbox = true,
                      windowbackgroundcolor = 0.9 * Color(:white)
                      )
    ad = plot(data; opts...)
    line(ad, Point(1,1), Point(4, 3); linestyle = LineStyle(Color(:green),2))
    save(ad, plotpath("test_axisbuilder10.pdf"))
    return true
end


# draw on existing plot
function main11()
    println("main11")
    data = Point[(x, x*x) for x in -0.1:0.01:1.85]
    d = plot(data)
    line(d, Point(1,1), Point(4, 3);linestyle = LineStyle(Color(:green), 2))
    save(d, plotpath("test_axisbuilder11.pdf"))
    return true
end



# basic two plots on same graph
function main12()
    println("main12")
    x1 = -2:0.1:2
    y1 = x1
    x2 = -0.5:0.1:0.7
    y2 = x2.*x2 .-3
    ad = AxisDrawable([PointList(pzip(x1, y1)); PointList(pzip(x2, y2))])
    drawaxis(ad)
    setclipbox(ad)
    line(ad, pzip(x1, y1); linestyle = LineStyle(Color(:red),1))
    line(ad, pzip(x2, y2); linestyle = LineStyle(Color(:blue),1))
    save(ad, plotpath("test_axisbuilder12.pdf"))
    return true
end


function main13()
    println("main13")
    ad = AxisDrawable(; xmin = -10, xmax = 20, ymin=-20, ymax=20)
    drawaxis(ad)
    setclipbox(ad)
    circle(ad, Point(0,0), 50; scaletype = :none, 
           linestyle = LineStyle(Color(:black), 4))
    save(ad, plotpath("test_axisbuilder13.pdf"))
    return true
end

# checking out limits
function main14()
    println("main14")
    x = collect(-2:0.01:2)
    y = x.*x
    f1 = plot(x, y)
    f2 = plot(x, y; xmin = -1, xmax = 1.5, ymax=5)
    f3 = plot(x, y; xmin = -1, xmax = 6.5)
    f4 = plot(x, y; ymin = -1, ymax = 10)
    save(hvbox([f1 f2; f3 f4]), plotpath("test_axisbuilder14.pdf"))
    return true
end

# checking out limits more
function main15()
    println("main15")
    x = collect(-1:0.01:2)
    y = x.*x
    f1 = plot(x, y)
    f2 = plot(x, y; xmax = 2.7) 
    f3 = plot(x, y; tickbox_xmax = 2.7, axisbox_xmax = 2.7)

    f4 = plot(x, y; tickbox_xmax = 1.3)
    f5 = plot(x, y; axisbox_xmax = 1.3)
    f6 = plot(x, y; axisbox_xmax = 1.3, tickbox_xmax = 1.3)
    save(hvbox([f1 f2 f3; f4 f5 f6]), plotpath("test_axisbuilder15.pdf"))
    return true 
end


# beziers
function main16()
    println("main16")

    ad = AxisDrawable(; xmin=0, xmax = 29, ymin = 0, ymax = 3,
                      yoriginatbottom = true, axisequal = false)

    p = Point(1,1)
    q = Point(6,2)
    th1 = pi/6
    th2 = pi/6
    
    # bad choice, angles wrong in axis space
    bezier = Bezier(p, q, th1, th2, 0.3)
    curve(ad, bezier; linestyle = LineStyle( Color(:black), 4))
    a = point(bezier, 0.3)
    circle(ad, a, 0.2;fillcolor = Color(:red))

    # good choice, angles correct in pixel space
    ax = ad.axis.ax
    bezier = Bezier(ax(p), ax(q), th1, th2, 0.3)
    curve(ad.ctx, bezier; linestyle = LineStyle(Color(:cyan), 1))
    a = point(bezier, 0.3)
    circle(ad.ctx, a, 5; fillcolor = Color(:green))
    
    save(ad, plotpath("test_axisbuilder16.pdf"))
    return true
end

# circles
function main17()
    println("main17")
    ad = AxisDrawable(; xmin=-2, xmax=15, ymin=-2, ymax=20)
    x = 1
    for i = 1:10
        circle(ad, Point(x, 5), 10; scaletype = :none, fillcolor = Color(:green))
        x += 1
    end
    for i = 1:10
        circle(ad, Point(i, 2), 10; scaletype = :none, fillcolor = Color(:red))
    end
    save(ad, plotpath("test_axisbuilder17.pdf"))
    return true
end

# offset two plots
function main18()
    println("main18")
    
    x1 = -0.1:0.1:1.3
    y1 = x1.*x1
    d1 = plot(x1, y1)

    x2 = -0.2:0.05:1.4
    y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)
    d2 = plot(x2, y2)

    ad = offset(d1, d2, 400, 200)
    save(ad, plotpath("test_axisbuilder18.pdf"))
    return true

end
