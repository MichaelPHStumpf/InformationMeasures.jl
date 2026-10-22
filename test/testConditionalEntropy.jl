@testset "Conditional entropy" begin
	rng = MersenneTwister(42)
	arr1 = rand(rng, 1000)
	arr2 = rand(rng, 1000)

	entropy1 = entropy(arr1)
	entropy2 = entropy(arr2)
	entropy12 = entropy(arr1, arr2)

	@testset "properties on random data" begin
		@test conditional_entropy(arr1, arr1) ≈ 0 atol = 0.05
		@test conditional_entropy(arr1, arr2) ≈ entropy12 - entropy2 atol = 0.05
		@test apply_conditional_entropy_formula(entropy12, entropy2) ≈ entropy12 - entropy2 atol = 0.05
		@test 0 <= conditional_entropy(arr1, arr2) <= entropy1 + 0.05
	end

	@testset "variable order (asymmetric fixture)" begin
		# x has 4 equally likely values (H = 2 bits), y is a function of x
		# with 2 values (H = 1 bit), so H(x|y) = 1 and H(y|x) = 0.
		# This test catches the swapped-marginal bug fixed in 0.4 (issue #35).
		x = repeat([1.0, 2.0, 3.0, 4.0], 25)
		y = repeat([5.0, 5.0, 6.0, 6.0], 25)
		@test conditional_entropy(x, y) ≈ 1 atol = 1e-9
		@test conditional_entropy(y, x) ≈ 0 atol = 1e-9
	end

	@testset "exact values on frequencies" begin
		# Joint frequencies xy with x rows, y columns.
		# Independent dice-like table:
		f_xy = [10 10; 10 10]
		# H(x|y) = H(x,y) - H(y) = 2 - 1 = 1
		@test conditional_entropy(f_xy) ≈ 1
		# Fully coupled table: x determines y.
		f_xy2 = [10 0; 0 10]
		@test conditional_entropy(f_xy2) ≈ 0
	end

	@testset "probabilities input" begin
		p_xy = [0.25 0.25; 0.25 0.25]
		@test conditional_entropy(p_xy, probabilities = true) ≈ 1
		p_xy2 = [0.5 0.0; 0.0 0.5]
		@test conditional_entropy(p_xy2, probabilities = true) ≈ 0
	end
end
