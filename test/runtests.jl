using InformationMeasures
using Test
using Random

@testset "InformationMeasures" begin
	include("testDiscretization.jl")
	include("testEstimators.jl")
	include("testEntropy.jl")
	include("testConditionalEntropy.jl")
	include("testMutualInformation.jl")
	include("testConditionalMutualInformation.jl")
	include("testInteractionInformation.jl")
	include("testTotalCorrelation.jl")
	include("testPartialInformationDecomposition.jl")
	include("testCrossEntropy.jl")
	include("testDeprecations.jl")
end
