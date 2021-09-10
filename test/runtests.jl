using MeanFilters
using Test
using MeanFilters: meanfilter!

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
end

    @test meanfilter([1 2 3; 4 5 6], (0:1, 0:0)) == [2.5 3.5 4.5; 4 5 6]

@testset "2d" begin
    arr = [1 2 3; 4 5 6]
    arr = randn(2,3)
    #arr = reshape(2:7, (2,3))
    expected = copy(arr)

    @test meanfilter(arr, (1,1)) ≈ expected
    out = similar(arr)
    @test meanfilter!(out, arr, (1,1)) ≈ expected
    @test out ≈ expected

    arr = [1 2 3; 4 5 6]
    @test meanfilter([1 2 3; 4 5 6], (0:1, 0:0)) == [2.5 3.5 4.5; 4 5 6]
end
