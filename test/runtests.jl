

##############################################################################
module TestMakeTicks
using Cairo
using PlotKitCairo
include("../src/maketicks.jl")
using .MakeTicks
using Test

function main()
    @testset "PlotKitAxes.MakeTicks" begin
        @test main1()
        @test main2()
    end
end
function main1()
    ticks = Ticks(0,1,0,1,10,10)
    return true
end
function main2()
    ticks = Ticks(0,1,0,1,4,5)
    return true
end
end
##############################################################################
module TestMakeAxisMap
using Cairo
using PlotKitCairo
include("../src/maketicks.jl")
using .MakeTicks
include("../src/makeaxismap.jl")
using .MakeAxisMap
using Test

function main()
    @testset "PlotKitAxes.MakeAxisMap" begin
        @test main1()
        @test main2()
    end
end
function main1()
    width = 800
    height = 600
    margins = (80,80,80,80)  # l,r,t,b
    yoriginatbottom = true
    axisequal = false
    b = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, b, axisequal, yoriginatbottom)
    return true
end
function main2()
    width = 800
    height = 600
    margins = (20,30,40,50)  # l,r,t,b
    yoriginatbottom = true
    axisequal = false
    b = Box(0,4,0,2)
    axismap = AxisMap(width, height, margins, b, axisequal, yoriginatbottom)
    return true
end
end
##############################################################################


module TestDrawAxis
using Cairo
using PlotKitCairo
include("../src/maketicks.jl")
using .MakeTicks
include("../src/makeaxismap.jl")
using .MakeAxisMap
include("../src/drawaxis.jl")
using .DrawAxis

using Test

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
end
##############################################################################

<<<<<<< HEAD
module TestAxisDrawables
using Cairo
using PlotKitCairo
include("../src/maketicks.jl")
using .MakeTicks
include("../src/makeaxismap.jl")
using .MakeAxisMap
include("../src/drawaxis.jl")
using .DrawAxis
include("../src/axisdrawables.jl")
using .AxisDrawables

using Test

plotpath(x) = joinpath(ENV["HOME"], "/tmp/", x)

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
    axisequal = false
    box = Box(0,1,0,1)
    axismap = AxisMap(width, height, margins, box, axisequal, yoriginatbottom)
    ticks = Ticks(box, 10, 10)
    as = AxisStyle()
    axis = Axis(axismap, box, ticks, as, yoriginatbottom)

    # drawing
    dw = Drawable(width, height; fname)
    ad = AxisDrawable(axis, dw)
    drawaxis(ad)
    line(ad, Point(0.1,0.2), Point(0.3,0.4); linestyle = LineStyle(Color(:red),1))
    close(ad)
    return true
end
end
##############################################################################
module TestAxisBuilder
using Cairo
using PlotKitCairo
include("../src/maketicks.jl")
using .MakeTicks
include("../src/makeaxismap.jl")
using .MakeAxisMap
include("../src/drawaxis.jl")
using .DrawAxis
include("../src/axisdrawables.jl")
using .AxisDrawables
include("../src/axisbuilder.jl")
using .AxisBuilder

using Test

plotpath(x) = joinpath(ENV["HOME"], "/tmp/", x)

function main()
    @testset "PlotKitAxes.AxisBuilder" begin
        @test main1()
    end
end
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
end
##############################################################################


using .TestMakeTicks
TestMakeTicks.main()

using .TestMakeAxisMap
TestMakeAxisMap.main()

using .TestDrawAxis
TestDrawAxis.main()

using .TestAxisDrawables
TestAxisDrawables.main()

using .TestAxisBuilder
TestAxisBuilder.main()


