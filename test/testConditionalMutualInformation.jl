@testset "Conditional mutual information" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 1000)
	arr2 = rand(rng, 1000)
	arr3 = rand(rng, 1000)

	entropy_xz = entropy(arr1, arr3)
	entropy_yz = entropy(arr2, arr3)
	entropy_xyz = entropy(arr1, arr2, arr3)
	entropy_z = entropy(arr3)

	cmi = entropy_xz + entropy_yz - entropy_xyz - entropy_z

	@testset "properties on random data" begin
		@test conditional_mutual_information(arr1, arr2, arr3) ≈ cmi atol = 0.01
		@test apply_conditional_mutual_information_formula(entropy_xz, entropy_yz, entropy_xyz, entropy_z) ≈ cmi atol = 0.01
	end

	@testset "exact values on frequencies" begin
		# 2x2x2 table, all 8 cells = 1: x, y, z mutually independent => CMI = 0.
		f_indep = ones(Int, (2, 2, 2))
		@test conditional_mutual_information(f_indep) ≈ 0 atol = 1e-12

		# z = XOR(x, y): x and y are independent marginally (MI = 0) but
		# dependent given z (CMI = 1).
		f_xor = zeros(Int, (2, 2, 2))
		for x in 1:2, y in 1:2
			f_xor[x, y, (x == y ? 1 : 2)] = 10
		end
		@test conditional_mutual_information(f_xor) ≈ 1 atol = 1e-12
		@test mutual_information(sum(f_xor, dims = 3)) ≈ 0 atol = 1e-12
	end
end
