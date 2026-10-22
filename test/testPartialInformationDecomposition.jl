@testset "Partial information decomposition" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 1000)
	arr2 = rand(rng, 1000)
	arr_and = [arr1[i] >= 0.5 && arr2[i] >= 0.5 ? 1.0 : 0.0 for i in eachindex(arr1)]

	@testset "AND gate" begin
		pid = partial_information_decomposition(arr1, arr2, arr_and)
		@test pid["redundancy"] ≈ 0.3 atol = 0.1
		@test pid["unique_1"] ≈ 0 atol = 0.1
		@test pid["unique_2"] ≈ 0 atol = 0.1
		@test pid["synergy"] ≈ 0.5 atol = 0.1
	end

	@testset "AND gate, all orientations" begin
		pid = partial_information_decomposition(arr1, arr2, arr_and, all_orientations = true)
		@test pid["z"]["redundancy"] ≈ 0.3 atol = 0.1
		@test pid["z"]["unique_1"] ≈ 0 atol = 0.1
		@test pid["z"]["unique_2"] ≈ 0 atol = 0.1
		@test pid["z"]["synergy"] ≈ 0.5 atol = 0.1
		@test pid["x"]["synergy"] ≈ 0.5 atol = 0.1
		@test pid["y"]["synergy"] ≈ 0.5 atol = 0.1
	end

	@testset "redundancy" begin
		red = redundancy(arr1, arr2, arr_and)
		@test red ≈ 0.3 atol = 0.1
		red_all = redundancy(arr1, arr2, arr_and, all_orientations = true)
		@test red_all[1] ≈ 0.3 atol = 0.1
	end

	@testset "unique and synergy formulae" begin
		mi = mutual_information(arr1, arr_and)
		red = redundancy(arr1, arr2, arr_and)
		@test apply_unique_information_formula(mi, red) ≈ 0 atol = 0.1
		ii = interaction_information(arr1, arr2, arr_and)
		@test apply_synergy_formula(ii, red) ≈ 0.5 atol = 0.1
	end

	@testset "exact values on frequencies" begin
		# Two identical sources and target: all information is redundant.
		# f[x, y, z] with x = y = z = binary.
		f = zeros(Int, (2, 2, 2))
		f[1, 1, 1] = 10
		f[2, 2, 2] = 10
		pid = partial_information_decomposition(f)
		@test pid["redundancy"] ≈ 1 atol = 1e-9
		@test pid["synergy"] ≈ 0 atol = 1e-9
		@test redundancy(f) ≈ 1 atol = 1e-9
	end

	@testset "PID consistency" begin
		# Redundancy + uniques + synergy must not be negative.
		pid = partial_information_decomposition(arr1, arr2, arr_and)
		@test all(values(pid) .>= 0)
	end
end
