@testset "Estimators" begin
	frequencies = [10, 20, 30, 40]

	@testset "maximum likelihood" begin
		@test probabilities("maximum_likelihood", frequencies) ≈ [0.1, 0.2, 0.3, 0.4]
	end

	@testset "dirichlet" begin
		expected = (frequencies .+ 1) ./ (sum(frequencies) + 4)
		@test probabilities("dirichlet", frequencies) ≈ expected
		expected_prior_2 = (frequencies .+ 2) ./ (sum(frequencies) + 8)
		@test probabilities("dirichlet", frequencies, prior = 2) ≈ expected_prior_2
	end

	@testset "shrinkage" begin
		p_auto = probabilities("shrinkage", frequencies)
		@test sum(p_auto) ≈ 1
		@test all(0 .<= p_auto .<= 1)
		p_lambda = probabilities("shrinkage", frequencies, lambda = 0)
		@test p_lambda ≈ frequencies ./ sum(frequencies)
		p_lambda_1 = probabilities("shrinkage", frequencies, lambda = 1)
		@test p_lambda_1 ≈ fill(1 / 4, 4)
	end

	@testset "unknown estimator" begin
		@test_throws ArgumentError probabilities("not_an_estimator", frequencies)
	end
end
