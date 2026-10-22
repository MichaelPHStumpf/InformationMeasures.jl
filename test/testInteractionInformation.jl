@testset "Interaction information" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 1000)
	arr2 = rand(rng, 1000)
	arr3 = rand(rng, 1000)

	cmi = conditional_mutual_information(arr1, arr2, arr3)
	mi = mutual_information(arr1, arr2)

	@testset "properties on random data" begin
		@test interaction_information(arr1, arr2, arr3) ≈ cmi - mi
		@test apply_interaction_information_formula(cmi, mi) ≈ cmi - mi
	end

	@testset "exact values on frequencies" begin
		# Independent variables: interaction information = 0.
		f_indep = ones(Int, (2, 2, 2))
		@test interaction_information(f_indep) ≈ 0 atol = 1e-12
	end
end
