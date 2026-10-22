@testset "Entropy" begin
	rng = MersenneTwister(42)
	arr = rand(rng, 1000)
	sqrt_1000 = sqrt(1000)

	@testset "one array" begin
		@test entropy(arr) ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, arr) ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, arr, arr) ≈ log2(sqrt_1000) atol = 0.05
	end

	@testset "discretization modes" begin
		@test entropy(arr, mode = "uniform_width") ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, mode = "uniform_count") ≈ log2(sqrt_1000) atol = 0.05
	end

	@testset "number of bins" begin
		@test entropy(arr, number_of_bins = 5) ≈ log2(5) atol = 0.05
		@test entropy(arr, get_number_of_bins = values -> 2) ≈ log2(2) atol = 0.05
	end

	@testset "estimators" begin
		@test entropy(arr, estimator = "maximum_likelihood") ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, estimator = "shrinkage") ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, estimator = "shrinkage", lambda = 0) ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, estimator = "dirichlet") ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, estimator = "dirichlet", prior = 1) ≈ log2(sqrt_1000) atol = 0.05
		@test entropy(arr, estimator = "miller_madow") ≈ log2(sqrt_1000) atol = 0.05
	end

	@testset "base" begin
		@test entropy(arr, base = ℯ) ≈ log(sqrt_1000) atol = 0.05
	end

	@testset "discretized input" begin
		@test entropy(discretize_values(arr), discretized = true) ≈ log2(sqrt_1000) atol = 0.05
	end

	@testset "exact values on frequencies" begin
		# Uniform distribution over 4 bins: H = 2 bits.
		@test entropy([25, 25, 25, 25], discretized = true) ≈ 2
		# Deterministic distribution: H = 0.
		@test entropy([0, 100, 0], discretized = true) ≈ 0
		# Known value: H([1,2,4]) = -(1/7)log2(1/7) - (2/7)log2(2/7) - (4/7)log2(4/7)
		expected = -(1/7) * log2(1/7) - (2/7) * log2(2/7) - (4/7) * log2(4/7)
		@test entropy([1, 2, 4], discretized = true) ≈ expected
	end

	@testset "miller_madow correction on discretized input" begin
		# The Miller-Madow bias correction is (K_observed - 1) / (2n) where n is
		# the sample count, not the number of bins.
		freqs = [50, 50, 0, 0]   # n = 100, 2 non-empty bins
		ml = entropy(freqs, discretized = true)
		mm = entropy(freqs, discretized = true, estimator = "miller_madow")
		@test mm ≈ ml + (2 - 1) / (2 * 100)
	end

	@testset "errors" begin
		@test_throws ArgumentError entropy(arr, estimator = "not_an_estimator")
		@test_throws ArgumentError entropy(arr, mode = "not_a_mode")
	end
end
