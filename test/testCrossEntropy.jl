@testset "Cross entropy" begin
	rng = MersenneTwister(42)
	arr21 = rand(rng, 100)
	arr22 = rand(rng, 100)
	arr41 = rand(rng, 10000)
	arr42 = rand(rng, 10000)

	@testset "properties on random data" begin
		@test cross_entropy(arr41, arr41) ≈ log2(100) atol = 0.01
		@test cross_entropy(arr21, arr21) ≈ entropy(arr21)
		@test cross_entropy(arr21, arr22) >= entropy(arr21) - 0.01
		@test cross_entropy(arr41, arr42) ≈ log2(100) atol = 0.02
	end

	@testset "exact values on frequencies" begin
		# Uniform distributions: H(p, p) = log2(4) = 2.
		f = [25, 25, 25, 25]
		@test cross_entropy(f, f, discretized = true) ≈ 2
		# Cross-entropy is not symmetric: H(p, q) != H(q, p).
		p = [10, 10]
		q = [15, 5]
		h_pq = cross_entropy(p, q, discretized = true)
		h_qp = cross_entropy(q, p, discretized = true)
		@test h_pq ≈ -(0.5 * log2(0.75) + 0.5 * log2(0.25)) atol = 1e-12
		@test h_qp ≈ -(0.75 * log2(0.5) + 0.25 * log2(0.5)) atol = 1e-12
		@test h_pq != h_qp
	end

	@testset "miller_madow warning" begin
		f = [25, 25, 25, 25]
		@test_warn "Miller-Madow" cross_entropy(f, f, discretized = true, estimator = "miller_madow")
	end
end
