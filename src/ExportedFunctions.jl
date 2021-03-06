# Exported functions

# TODO:
# Add tests for the sensibleness of mi and cmi
# Offer alternative target
# Look into standardising the documentation
# Implement (or find implementation of) Bayesian blocks in Julia,
# 	to not be dependent on the Python module

export get_shrinkage_entropy, get_shrinkage_mi, get_shrinkage_cmi, get_shrinkage_total_correlation

"""
Calculates a James-Stein shrinkage estimate for the entropy of a set
of observed values, via the following steps:
(1) convert the observed values to frequencies of discrete bins
(2) convert the frequencies to probablities using shrinkage estimation
(3) run the probabilities through the entropy formula.
Can calculate joint entropy for up to 3 sets of observed values.

Parameters:

valuesX - dxn Array{Float64,2} - The observed values, where d is
the number of dimensions and n is the number of values.

[valuesY] - dxn Array{Float64,2} - The observed values, where d is
the number of dimensions and n is the number of values.

[valuesZ] - dxn Array{Float64,2} - The observed values, where d is
the number of dimensions and n is the number of values.

Keyword arguments:

[base=2] - the base of the logarithm, which determines the units
[lambda=nothing] - the shrinkage intensity, between 0 and 1 inclusive, which
		will be calculated if this value is not given
[mode="uniformwidth"] - the discretization mode: "uniformwidth", "uniformcount" or
		"bayesianblocks"
"""
function get_shrinkage_entropy(valuesX::Array{Float64,2}; base::Number = 2, lambda = nothing, mode::ASCIIString = "uniformwidth")
	probabilities = getprobabilitiesshrinkage(getfrequencies(valuesX, mode), lambda)
	return applyentropyformula(probabilities, base)
end
function get_shrinkage_entropy(valuesX::Array{Float64,2}, valuesY::Array{Float64,2}; base::Number = 2, lambda = nothing, mode::ASCIIString = "uniformwidth")
	jointprobabilities = getprobabilitiesshrinkage(getjointfrequencies(valuesX, valuesY, mode), lambda)
	return applyentropyformula(jointprobabilities, base)
end
function get_shrinkage_entropy(valuesX::Array{Float64,2}, valuesY::Array{Float64,2}, valuesZ::Array{Float64,2}; base::Number = 2, lambda = nothing, mode::ASCIIString = "uniformwidth")
	jointprobabilities = getprobabilitiesshrinkage(getjointfrequencies(valuesX, valuesY, valuesZ, mode), lambda)
	return applyentropyformula(jointprobabilities, base)
end

"""
Calculates a James-Stein shrinkage estimate for the mutual information
between two sets of observed values.

Parameters:

valuesX - dxn Array{Float64,2} - A set of observed values, where d is
the number of dimensions and n is the number of values.

valuesY - dxn Array{Float64,2} - Another set of observed values, where
d is the number of dimensions and n is the number of values.

Keyword arguments:

[base=2] - the base of the logarithm, which determines the units
[lambda=nothing] - the shrinkage intensity, between 0 and 1 inclusive, which
		will be calculated if this value is not given
[mode="uniformwidth"] - the discretization mode: "uniformwidth", "uniformcount" or
		"bayesianblocks"
"""
# NB "mi" stands for mutual information
function get_shrinkage_mi(valuesX::Array{Float64,2}, valuesY::Array{Float64,2}; base::Number = 2, lambda = nothing, mode::ASCIIString = "uniformwidth")
	entropyX = get_shrinkage_entropy(valuesX, base = base, lambda = lambda, mode = mode)
	entropyY = get_shrinkage_entropy(valuesY, base = base, lambda = lambda, mode = mode)
	entropyXY = get_shrinkage_entropy(valuesX, valuesY, base = base, lambda = lambda, mode = mode)
	return applymutualinformationformula(entropyX, entropyY, entropyXY)
end

"""
Calculates a James-Stein shrinkage estimate for the conditional mutual
information between two sets of observed values, given a third set of
observed values.

Parameters:

valuesX - dxn Array{Float64,2} - A set of observed values, where d is
the number of dimensions and n is the number of values.

valuesY - dxn Array{Float64,2} - Another set of observed values, where
d is the number of dimensions and n is the number of values.

valuesZ - dxn Array{Float64,2} - The set of observed values, that will
be conditioned on, where d is the number of dimensions and n is the
number of values.

Keyword arguments:

[base=2] - the base of the logarithm, which determines the units
[lambda=nothing] - the shrinkage intensity, between 0 and 1 inclusive, which
		will be calculated if this value is not given
[mode="uniformwidth"] - the discretization mode: "uniformwidth", "uniformcount" or
		"bayesianblocks"
"""
# NB "cmi" stands for conditional mutual information
function get_shrinkage_cmi(valuesX::Array{Float64,2}, valuesY::Array{Float64,2}, valuesZ::Array{Float64,2}; base::Number = 2, lambda = nothing, mode::ASCIIString = "uniformwidth")
	entropyZ = get_shrinkage_entropy(valuesZ, base = base, lambda = lambda, mode = mode)
	entropyXZ = get_shrinkage_entropy(valuesX, valuesZ, base = base, lambda = lambda, mode = mode)
	entropyYZ = get_shrinkage_entropy(valuesY, valuesZ, base = base, lambda = lambda, mode = mode)
	entropyXYZ = get_shrinkage_entropy(valuesX, valuesY, valuesZ, base = base, lambda = lambda, mode = mode)
	return applyconditionalmutualinformationformula(entropyZ, entropyXZ, entropyYZ, entropyXYZ)
end

function get_shrinkage_total_correlation(valuesX::Array{Float64,2}, valuesY::Array{Float64,2}, valuesZ::Array{Float64,2}; base::Number = 2, lambda = nothing, mode::ASCIIString = "uniformwidth")
	entropyX = get_shrinkage_entropy(valuesX, base = base, lambda = lambda, mode = mode)
	entropyY = get_shrinkage_entropy(valuesY, base = base, lambda = lambda, mode = mode)
	entropyZ = get_shrinkage_entropy(valuesZ, base = base, lambda = lambda, mode = mode)
	entropyXYZ = get_shrinkage_entropy(valuesX, valuesY, valuesZ, base = base, lambda = lambda, mode = mode)
	return applytotalcorrelationformula(entropyX, entropyY, entropyZ, entropyXYZ)
end
