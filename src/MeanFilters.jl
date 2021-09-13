module MeanFilters

export meanfilter

const Window{N} = NTuple{N,UnitRange{Int}}

function alloc_output(x::AbstractArray)
    T = float(eltype(x))
    return similar(x, T)
end

function meanfilter1d(v::AbstractVector, window::UnitRange{Int})
    out = alloc_output(v)
    meanfilter1d!(out, v, window)
end

function meanfilter1d!(out, v::AbstractVector, window::UnitRange{Int})
    # out and v may not alias!
    if isempty(v)
        return out
    end
    firstindex_v = firstindex(v)
    lastindex_v = lastindex(v)
    eachindex_v = eachindex(v)

    max_window_len = length(window)
    i_pix   = firstindex_v
    i_left  = i_pix + first(window)
    i_right = i_pix + last(window)
    inds_first_window = clamp(i_left, firstindex_v, lastindex_v):clamp(i_right, firstindex_v, lastindex_v)
    window_len = length(inds_first_window)
    T = eltype(out)
    sum = T(Base.sum(view(v, inds_first_window)))
    out[i_pix] = sum/window_len
    # could factor this out into a fringe_loop function
    # and implement meanfilter by
    # fringe_loop(left)
    # branchless_main_loop(middle)
    # fringe_loop(right)
    while true
        i_pix += 1
        i_right += 1
        i_left += 1
        if i_pix > lastindex_v
            return out
        end
        if i_right in eachindex_v
            window_len += 1
            sum += v[i_right]
        end
        if i_left-1 in eachindex_v
            window_len -= 1
            sum -= v[i_left-1]
        end
        out[i_pix] = sum / window_len
    end
    return out
end

function resolve_range(r::AbstractRange)
    resolve_range(UnitRange{Int}(r))
end
function resolve_range(r::UnitRange{Int})
    if first(r) <= 0 <= last(r)
        return r
    else
        msg = """
        Range must contain 0. Got $r
        """
        throw(ArgumentError(msg))
    end
end
function resolve_range(x::Number)
    i = Int(x)
    if i < 1
        msg = """
        Window size must be at least 1. Got $x instead.
        """
        throw(ArgumentError(msg))
    elseif isodd(i)
        h = i÷2
        return (-h:h)
    else
        msg = """
        Window size must be odd. Got $x instead.
        """
        throw(ArgumentError(msg))
    end
end

function resolve_window(n::Integer)
    r = resolve_range(n)
    return (r,)
end
function resolve_window(r::AbstractRange)
    return resolve_window((r,))
end
function resolve_window(window)
    map(resolve_range, window)
end

function _meanfilter(x::AbstractArray{T,N}, window::Window{N}) where {T,N}
    out = alloc_output(x)
    return _meanfilter!(out, x, window)
end

"""
    out, buf2 = _meanfilter_along_axis!!!(buf, inp, axis)

`buf` and `inp` may not alias. `inp` contains the input and `buf` may contain
arbitrary junk data. After calling this function `buf, buf2, inp` contain arbitrary junk.
It `out === buf && buf2 === inp` or `out === inp && buf2 === buf` will hold.
"""
function _meanfilter_along_axis!!!(out, inp, window::Window, axis)
    N = ndims(out)
    @assert axis in 1:N
    # return out, buf such that
    r = window[axis]
    if window === 0:0
        return (inp, out)
    end
    if N === 1
        meanfilter1d!(out, inp, r)
    elseif N === 2
        if axis === 1
            Threads.@threads for iy in axes(out, 2)
                meanfilter1d!(view(out,:,iy), view(inp,:,iy), r)
            end
        else
            @assert axis === 2
            Threads.@threads for ix in axes(out, 1)
                meanfilter1d!(view(out,ix,:), view(inp,ix,:), r)
            end
        end
    else
        grid = Base.setindex(axes(out), Base.OneTo(1), axis)
        Threads.@threads for I in CartesianIndices(grid)
            inds = Base.setindex(Tuple(I), (:), axis)
            meanfilter1d!(view(out, inds...), view(inp,inds...), r)
        end
    end
    return (out, inp)
end

function _meanfilter!(out::AbstractVector, arr::AbstractVector, window::Window{1})
    inp = similar(out)
    copy!(inp, arr)
    out, _ = _meanfilter_along_axis!!!(out, inp, window, 1)
    return out
end

function _meanfilter!(out::AbstractMatrix, arr::AbstractMatrix, window::Window{2})
    inp = similar(out)
    copy!(inp, arr)
    inp, out = _meanfilter_along_axis!!!(out, inp, window, 1)
    inp, out = _meanfilter_along_axis!!!(out, inp, window, 2)
    return inp
end
function _meanfilter!(out::AbstractArray{T2,N}, arr::AbstractArray{T1,N}, window::Window{N}) where {T1,T2,N}
    inp = similar(out)
    copy!(inp, arr)
    for axis in 1:ndims(out)
        inp, out = _meanfilter_along_axis!!!(out, inp, window, axis)
    end
    return inp
end

function meanfilter!(out, arr, window)
    w::Window = resolve_window(window)
    if ndims(arr) !== length(w)
        msg = """
        Number of array and window dimensions must coincide. Got:
        ndims(arr) = $(ndims(arr))
        length(window) = $(length(w))
        """
        throw(ArgumentError(msg))
    end
    out2 = _meanfilter!(out, arr, w)
    if out2 !== out
        copy!(out, out2)
    end
    return out
end
function meanfilter(arr, window)
    out = alloc_output(arr)
    return meanfilter!(out, arr, window)
end

end
