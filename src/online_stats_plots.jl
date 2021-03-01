function onlineplot!(scene, layout, axis_dict, stats::Series, iter, data, variable, i)
    for (j, stat) in enumerate(stats.stats)
        axis_dict[(variable, stat)] = layout[i, j] = Axis(scene, title = "$(name(stat))")
        limits!(layout[i, j], 0, 10, -1, 1)
        onlineplot!(axis_dict[(variable, stat)], stat, iter, data[variable], data[:iter], i, j)
        tight_ticklabel_spacing!(axis_dict[(variable, stat)])
    end
end

function onlineplot!(scene, layout, axis_dict, stats::AbstractVector, iter, data, variable, i)
    for (j, stat) in enumerate(stats)
        axis_dict[(variable, stat)] = layout[i, j] = Axis(scene, title = "$(name(stat))")
        onlineplot!(axis_dict[(variable, stat)], stat, iter, data[variable], data[:iter], i, j)
        tight_ticklabel_spacing!(axis_dict[(variable, stat)])
    end
end

function onlineplot!(axis, stat::Symbol, args...)
    onlineplot!(axis, Val(stat), args...)
end

onlineplot!(axis, ::Val{:mean}, args...) = onlineplot!(axis, Mean(), args...)

onlineplot!(axis, ::Val{:var}, args...) = onlineplot!(axis, Variance(), args...)

onlineplot!(axis, ::Val{:autocov}, args...) = onlineplot!(axis, AutoCov(20), args...)

onlineplot!(axis, ::Val{:hist}, args...) = onlineplot!(axis, KHist(50, Float32), args...)

onlineplot!(axis, ::Val{:ash}, args...) = onlineplot!(axis, ash(randn(Float32, 50)), args...)

# Generic fallback for OnlineStat objects
function onlineplot!(axis, stat::T, iter, data, iterations, i, j) where {T<:OnlineStat}
    window = data.b
    @eval TStat = $(nameof(T))
    stat = Node(TStat(Float32))
    on(iter) do i
        stat[] = fit!(stat[], last(value(data)))
    end
    statvals = Node(MovingWindow(window, Float32))
    on(stat) do s
        statvals[] = fit!(statvals[], Float32(value(s)))
    end
    statpoints = lift(statvals; init = Point2f0.([0], [0])) do v
        Point2f0.(value(iterations), value(v))
    end
    lines!(axis, statpoints, color = std_colors[i], linewidth = 3.0)
end

function onlineplot!(axis, ::Val{:trace}, iter, data, iterations, i, j)
    trace = lift(iter; init = [Point2f0(0, 0f0)]) do i
        Point2f0.(value(iterations), value(data))
    end
    lines!(axis, trace, color = std_colors[i]; linewidth = 3.0)
end

function onlineplot!(axis, stat::KHist, iter, data, iterations, i, j)
    nbins = stat.k
    stat = Node(KHist(nbins, Float32))
    on(iter) do i
        stat[] = fit!(stat[], last(value(data)))
    end
    hist_vals = lift(stat; init = Point2f0.(range(0, 1, length = nbins), zeros(Float32, nbins))) do h
        edges, weights = OnlineStats.xy(h)
        weights = nobs(h) > 1 ? weights / OnlineStats.area(h) : weights
        return Point2f0.(edges, weights)
    end
    barplot!(axis, hist_vals, color = std_colors[i])
end

function expand_extrema(xs)
    xmin, xmax = xs
    diffx = xmax - xmin
    xmin = xmin - 0.1 * abs(diffx)
    xmax = xmax + 0.1 * abs(diffx)
    return (xmin, xmax)
end

function onlineplot!(axis, ::Val{:kde}, iter, data, iterations, i, j)
    interpkde = Node(InterpKDE(kde([1f0])))
    on(iter) do i
        interpkde[] = InterpKDE(kde(value(data)))
    end
    xs = lift(iter; init = range(0.0, 2.0, length = 200)) do i
        range(expand_extrema(extrema(value(data)))..., length = 200)
    end
    kde_pdf = lift(xs) do xs
        pdf.(Ref(interpkde[]), xs)
    end
    lines!(axis, xs, kde_pdf, color = std_colors[i], linewidth = 3.0)
end

name(s::Val{:histkde}) = "Hist + KDE"

function onlineplot!(axis, ::Val{:histkde}, iter, data, iterations, i, j)
    onlineplot!(axis, KHist(50), iter, data, iterations, i, j)
    onlineplot!(axis, Val(:kde), iter, data, iterations, i, j)
end

function onlineplot!(axis, hist::AverageShiftedHistograms.Ash, iter, data, iterations, i, j)
    hist = Node(hist)
    on(iter) do i
        if i == min(20, data.b ÷ 10)
            hist[] = ash(value(data), m=hist[].m, kernel=hist[].kernel)
        else
            ash!(hist[], value(data))
        end
    end
    xs = lift(iter; init = range(0.0, 2.0, length=200)) do i
        range(expand_extrema(extrema(value(data)))..., length = 200)
    end
    ash_pdf = lift(xs) do xs
        AverageShiftedHistograms.pdf.(Ref(hist[]), xs)
    end
    ash_hist = lift(hist; init = Point2f0.(range(0, 1, length = length(hist[].rng)), zeros(Float32, length(hist[].rng)))) do h
        edges, weights = AverageShiftedHistograms.xy(h)
        # weights = nobs(h) > 1 ? weights / OnlineStats.area(h) : weights
        return Point2f0.(edges, weights)
    end
    barplot!(axis, ash_hist, color = std_colors[i])
    lines!(axis, xs, ash_pdf, color = :black, linewidth = 3.0)
end

function onlineplot!(axis, stat::AutoCov, iter, data, iterations, i, j)
    b = length(stat.cross)
    stat = Node(AutoCov(b, Float32))
    on(iter) do i
        stat[] = fit!(stat[], last(value(data)))
    end
    statvals = lift(stat; init = zeros(Float32, b + 1)) do s
        value(s)
    end
    scatter!(axis, Point2f0.([0.0, b], [-0.1, 1.0]), markersize = 0.0, color = RGBA(0.0, 0.0, 0.0, 0.0)) # Invisible points to keep limits fixed
    lines!(axis, 0:b, statvals, color = std_colors[i], linewidth = 3.0)
end
