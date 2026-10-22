# InformationMeasures v0.4 local test environment

This directory is a scratch Julia environment for trying out the new version
locally. It is safe to delete at any time.

## Setup (one-off)

```julia
using Pkg
Pkg.develop(path=dirname(pwd()))   # makes the local repo copy of InformationMeasures v0.4 available
Pkg.add("Discretizers")
```

or from the shell:

```sh
julia --project=. -e 'using Pkg; Pkg.develop(path=dirname(pwd())); Pkg.instantiate()'
```

## Try it

Start Julia with `julia --project=.` then:

```julia
using InformationMeasures

data_1 = rand(100)
data_2 = rand(100)

entropy(data_1)
mutual_information(data_1, data_2)
conditional_entropy(data_1, data_2)   # now correctly H(x|y)

# old names still work but warn:
get_entropy(data_1)
```

## Run the test suite

```sh
julia --project=. -e 'using Pkg; Pkg.test("InformationMeasures")'
```
