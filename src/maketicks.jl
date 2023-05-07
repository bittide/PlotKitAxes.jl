
module MakeTicks

using ..PlotKitCairo: Box

export Ticks

# Ticks and its constructor


Base.@kwdef mutable struct Ticks
    xticks = missing
    xtickstrings = missing
    yticks = missing
    ytickstrings = missing
end


function Ticks(xmin, xmax, ymin, ymax, xidealnumlabels, yidealnumlabels)
    xt = best_ticks(xmin, xmax, xidealnumlabels)
    yt = best_ticks(ymin, ymax, yidealnumlabels)
    xl = best_labels(xt)
    yl = best_labels(yt)
    ticks =  Ticks(xt, xl, yt, yl)
    return  ticks
end

# b is a box in data units
# it specifies the minimum region which the ticks enclose
Ticks(b::Box, xidl, yidl) = Ticks(b.xmin, b.xmax, b.ymin, b.ymax, xidl, yidl)


closefloor(x,e) =  floor(x) < floor(x+e) ?  floor(x+e) :  floor(x)
closeceil(x,e) =    ceil(x) > ceil(x-e) ?    ceil(x-e) :   ceil(x)
pospart(x) = x>0 ? x : zero(x)

function score_ticks(x, dmin, dmax, i, exponent, idealnumlabels)
    lspacing = (10.0^exponent) * x[i]
    allowederror = (dmax-dmin)/1000/lspacing
    jmin = Int64(closefloor(dmin/lspacing, allowederror))
    jmax = Int64(closeceil(dmax/lspacing, allowederror))
    nlabels = jmax-jmin+1
    coverage = (dmax-dmin)/(jmax*lspacing-jmin*lspacing)
    simplicity = 1-i/length(x)
    includeszero = jmin*lspacing<=0 && jmax*lspacing>=0
    density = 1-(abs(nlabels-idealnumlabels)/idealnumlabels)
    score =  coverage + simplicity + 2*pospart(density) + includeszero
    return score,jmin,jmax,nlabels
end


function best_ticks(dmin, dmax, idealnumlabels=10)
    if dmax == 0 && dmin == 0
        dmax = 1
    elseif dmax == dmin
        dmax = 1.1*dmin
        dmin = 0.9*dmin
    end
    labels = 0
    bestscore = -1
    x  = [1, 5, 2, 2.5]
    for i = 1:length(x)
        emin = Int64(floor(log10(abs(dmax-dmin)/(20*x[i]))))
        emax = Int64(ceil(log10(abs(dmax-dmin)/(0.5*x[i]))))
        for exponent = emin:emax
            score, jmin, jmax, nlabels = score_ticks(x, dmin, dmax, i, exponent, idealnumlabels)
            if score > bestscore
                labels = collect(jmin:jmax)*x[i]*(10.0^exponent)
                bestscore = score
            end
        end
    end
    if labels == 0
        return [0.0, 1.0]
    end
    return labels
end

best_ticks(x) = best_ticks(minimum(x), maximum(x))


function get_tick_extents(t::Ticks)
    xmin, xmax, ymin, ymax = minimum(t.xticks), maximum(t.xticks), minimum(t.yticks), maximum(t.yticks)
    return Box(xmin, xmax, ymin, ymax)
end


##############################################################################
# labels

num_to_string(x::Float64, precision) = Base.Ryu.writefixed(x, precision)
num_to_string(x::Integer, precision) = Base.Ryu.writefixed(1.0*x, precision)

function labelsequal(x, l)
    for i=1:length(x)
        if x[i] != 0.0 && abs(x[i] - parse(Float64, l[i])) / abs(x[i]) > 1e-12
            return false
        end
    end
    return true
end

# given a list of numbers, convert to a list of strings
function best_labels(x::Array{Integer,1}, suffix = "")
    y = string.(x)
    y[end] *= suffix
    return y
end
    

function best_labels(x::Array{Float64,1}, suffix = "")
    if maximum(abs.(x)) > 10^6 && maximum(x) - minimum(x) > 10^7
        return best_labels(x ./ 10^6, "e6")
    end
    if maximum(abs.(x)) < 10^-6
        return best_labels(x .* 10^6, "e-6")
    end
    for p in 0:20
        plabels = num_to_string.(x, p)
        if labelsequal(x, plabels)
            plabels[end] *= suffix
            return plabels
        end
    end
end

end
