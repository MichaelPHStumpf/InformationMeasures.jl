@testset "Discretization" begin
	rng = MersenneTwister(42)
	arr = rand(rng, 100)

	@testset "dimensions" begin
		@test size(discretize_values(arr)) == (10, 1)
		@test size(discretize_values(arr, arr)) == (10, 10)
		@test size(discretize_values(arr, arr, arr)) == (10, 10, 10)
		@test size(discretize_values(arr, arr, arr, arr)) == (10, 10, 10, 10)
	end

	@testset "modes" begin
		@test size(discretize_values(arr, mode = "uniform_width")) == (10, 1)
		@test size(discretize_values(arr, mode = "uniform_count")) == (10, 1)
		@test size(discretize_values(arr, mode = "binarize")) == (2, 1)
		@test size(discretize_values(arr, mode = "bayesian_blocks"))[1] >= 1
	end

	@testset "number of bins" begin
		@test size(discretize_values(arr, number_of_bins = 5)) == (5, 1)
		@test size(discretize_values(arr, get_number_of_bins = values -> 2)) == (2, 1)
	end

	@testset "constant values" begin
		freqs = discretize_values(fill(3.0, 10))
		@test size(freqs) == (1, 1)
		@test freqs[1] == 10
		@test size(discretize_values(fill(3.0, 10), fill(5.0, 10))) == (1, 1)
	end

	@testset "bin ids fallback" begin
		# Data that breaks uniform_count (repeated quantile values) must not
		# produce zero bin ids (the pre-0.4 fallback bug).
		pathological = vcat(fill(1.0, 50), fill(2.0, 45), fill(3.0, 5))
		freqs = discretize_values(pathological, mode = "uniform_count")
		@test sum(freqs) == length(pathological)
	end

	@testset "errors" begin
		@test_throws ArgumentError discretize_values(arr, mode = "not_a_mode")
	end
end
