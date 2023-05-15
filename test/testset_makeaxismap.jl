
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

