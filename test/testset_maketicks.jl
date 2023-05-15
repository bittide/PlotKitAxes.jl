

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

