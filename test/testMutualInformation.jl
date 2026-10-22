@testset "Mutual information" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 1000)
	arr2 = rand(rng, 1000)
	arr3 = rand(rng, 1000)

	entropy1 = entropy(arr1)
	entropy2 = entropy(arr2)
	entropy12 = entropy(arr1, arr2)

	mi = entropy1 + entropy2 - entropy12

	@testset "properties on random data" begin
		@test mutual_information(arr1, arr2) ≈ mi
		@test apply_mutual_information_formula(entropy1, entropy2, entropy12) ≈ mi
		# MI is symmetric.
		@test mutual_information(arr1, arr2) ≈ mutual_information(arr2, arr1)
		# Independent variables have MI near zero... but with plug-in
		# estimation on binned data it is slightly positive.
		@test mutual_information(arr1, arr3) >= 0
		# A variable has zero MI with itself only if deterministic;
		# for random data MI(x, x) = H(x).
		@test mutual_information(arr1, arr1) ≈ entropy1 atol = 0.05
	end

	@testset "exact values on frequencies" begin
		# Independent: MI = 0.
		@test mutual_information([10 10; 10 10]) ≈ 0 atol = 1e-12
		# Fully coupled: MI = H(x) = 1 bit.
		@test mutual_information([10 0; 0 10]) ≈ 1
		# Asymmetric table where the old swapped-marginal code was wrong.
		# P(x,y): x in {0,1}, y in {0,1,2}
		# rows: x=0 -> y=0 twice, y=1 once; x=1 -> y=2 three times
		f = [2 1 0; 0 0 3]
		# H(x) = -(3/6)log2(3/6) - (3/6)log2(3/6) = 1
		# H(y) = -(2/6)log2(2/6) - (1/6)log2(1/6) - (3/6)log2(3/6)
		# H(x,y) = same as H(y) since y determines x
		# MI = H(x) + H(y) - H(x,y) = 1
		@test mutual_information(f) ≈ 1 atol = 1e-12
	end

	@testset "estimators" begin
		@test mutual_information(arr1, arr2, estimator = "miller_madow") >= 0
		@test mutual_information(arr1, arr2, estimator = "dirichlet") >= 0
	end
end
