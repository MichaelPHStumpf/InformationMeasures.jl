@testset "Total correlation" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 1000)
	arr2 = rand(rng, 1000)
	arr3 = rand(rng, 1000)

	entropy1 = entropy(arr1)
	entropy2 = entropy(arr2)
	entropy3 = entropy(arr3)
	entropy123 = entropy(arr1, arr2, arr3)

	tc = entropy1 + entropy2 + entropy3 - entropy123

	@testset "properties on random data" begin
		@test total_correlation(arr1, arr2, arr3) ≈ tc
		@test apply_total_correlation_formula(entropy1, entropy2, entropy3, entropy123) ≈ tc
	end

	@testset "exact values on frequencies" begin
		# Independent variables: TC = 0.
		f_indep = ones(Int, (2, 2, 2))
		@test total_correlation(f_indep) ≈ 0 atol = 1e-12
		# All three identical binary variables: TC = 3*H(x) - H(x,y,z) = 2 bits.
		f_same = zeros(Int, (2, 2, 2))
		f_same[1, 1, 1] = 10
		f_same[2, 2, 2] = 10
		@test total_correlation(f_same) ≈ 2
	end
end
