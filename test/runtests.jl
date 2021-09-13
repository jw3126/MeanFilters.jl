using MeanFilters
using Test
using MeanFilters: meanfilter!
using ImageFiltering: imfilter, NA
using ImageFiltering.OffsetArrays: OffsetArray

@testset "1d" begin
    @test meanfilter([1,2,3,4], -1:1) ≈ [1.5, 2, 3, 3.5]
    @test meanfilter([1,2,3], (0:1,)) == [1.5, 2.5, 3.0]
    @test meanfilter([1,4], (0:1,)) == [2.5, 4]
    @test meanfilter([3,6], (0:1,)) == [4.5, 6]
    @test meanfilter([0,0,1,0,0], (-1:1,)) ≈ [0, 1/3, 1/3, 1/3, 0]
    @test meanfilter([0,0,1,0,0], (-1:0,)) ≈ [0,   0, 1/2, 1/2, 0]
    @test meanfilter([0,0,1,0,0], (-1:2,)) ≈ [1/3, 1/4, 1/4, 1/3, 0]
    @test meanfilter([1,0,0,0,0], (-1:2,)) ≈ [1/3, 1/4, 0, 0, 0]
    @test meanfilter([1,2,], (-0:0,)) ≈ [1,2]

    @test_throws ArgumentError meanfilter([1,2,3], (1:2, 2:3))
end

@testset "2d" begin
    arr = [1 2 3; 4 5 6]
    arr = randn(2,3)
    expected = copy(arr)

    @test meanfilter(arr, (1,1)) ≈ expected
    out = similar(arr)
    @test meanfilter!(out, arr, (1,1)) ≈ expected
    @test out ≈ expected

    arr = [1 2 3; 4 5 6]
    @test meanfilter([1 2 3; 4 5 6], (0:1, 0:0)) == [2.5 3.5 4.5; 4 5 6]
end

@testset "against ImageFiltering.imfilter" begin

    function meanfilter_reference(arr, window)
        ker = fill(1/prod(map(length,window)), window...)
        imfilter(arr, ker, NA())
    end

    for arr in [randn(1), randn(1,2), randn(1,2,3), randn(1,2,3,4), randn(1,2,3,4,5)]
        window = Tuple(0:0 for _ in 1:ndims(arr))
        @test meanfilter(arr, window) ≈ arr
        @test meanfilter(arr, window) ≈ meanfilter_reference(arr, window)
    end

    for ndims in 1:2
        for _ in 1:100
            #ndims = rand(1:2)
            arr = randn(rand(1:10, ndims)...)
            window = Tuple(-rand(0:10):rand(0:10) for _ in 1:ndims)
            @test meanfilter(arr, window) ≈ meanfilter_reference(arr, window)
        end
    end
    for ndims in 3:5
        #ndims = rand(1:2)
        arr = randn(rand(1:10, ndims)...)
        window = Tuple(-rand(0:2):rand(0:2) for _ in 1:ndims)
        @test meanfilter(arr, window) ≈ meanfilter_reference(arr, window)
    end
end
