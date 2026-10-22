@testset "Deprecations" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 100)
	arr2 = rand(rng, 100)
	arr3 = rand(rng, 100)

	@testset "aliases still work and warn" begin
		@test_deprecated get_probabilities("maximum_likelihood", [1, 2, 3])
		@test_deprecated get_entropy(arr1)
		@test_deprecated get_conditional_entropy(arr1, arr2)
		@test_deprecated get_mutual_information(arr1, arr2)
		@test_deprecated get_conditional_mutual_information(arr1, arr2, arr3)
		@test_deprecated get_interaction_information(arr1, arr2, arr3)
		@test_deprecated get_total_correlation(arr1, arr2, arr3)
		@test_deprecated get_partial_information_decomposition(arr1, arr2, arr3)
		@test_deprecated get_redundancy(arr1, arr2, arr3)
		@test_deprecated get_cross_entropy(arr1, arr2)
	end

	@testset "aliases return the same values" begin
		@test get_entropy(arr1) == entropy(arr1)
		@test get_mutual_information(arr1, arr2) == mutual_information(arr1, arr2)
		@test get_conditional_entropy(arr1, arr2) == conditional_entropy(arr1, arr2)
		@test get_cross_entropy(arr1, arr2) == cross_entropy(arr1, arr2)
	end
end
