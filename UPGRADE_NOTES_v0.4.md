# InformationMeasures.jl — Proposed v0.4.0 Update

## Background

Following a full review of the package (v0.3.1, last updated Jan 2023), a set of correctness bugs, test-suite deficiencies, and packaging issues was identified. All fixes have been implemented, tested (107/107 tests passing on Julia 1.13.2), and merged to a fork at [MichaelPHStumpf/InformationMeasures.jl](https://github.com/MichaelPHStumpf/InformationMeasures.jl). This document summarises the changes for review before they are proposed upstream.

## 1. Correctness fixes

### 1.1 Conditional entropy direction (issue [#35](https://github.com/Tchanders/InformationMeasures.jl/issues/35))
`get_conditional_entropy(x, y)` returned **H(y|x)** instead of **H(x|y)** — the marginals were summed over the wrong dimensions (`dims = 2` instead of `dims = 1`). This was confirmed with an asymmetric test case: with `x` having 4 equally likely values and `y` a deterministic function of `x` with 2 values, the old code returned 0.0 for H(x|y) where the true value is 1.0.

The same swapped-marginal pattern was found and fixed in `mutual_information` and `conditional_mutual_information`. Because the existing test data was symmetric (`rand` arrays), these bugs were invisible to the old test suite.

### 1.2 Miller–Madow bias correction
The correction term is defined as `(K−1)/(2n)` where `n` is the **sample count**. The code divided by the number of bins instead when `discretized=true`, making the correction wrong by a factor of n/bins. Now fixed throughout (entropy, conditional entropy, MI, CMI), with a `@warn` in paths where probabilities are supplied and `n` is unknown.

### 1.3 Fallback bug in `uniform_count`
When `uniform_count` failed, the `catch` block rebound `bin_ids` to a new local array rather than writing into the pre-allocated one — so the fallback silently assigned **all points to bin 0**, producing completely wrong frequencies. Fixed; a regression test with pathological data (repeated quantile values) is included. The `bayesian_blocks` fallback had the same style issue and is also fixed. Both now emit `@warn` messages instead of `println`.

### 1.4 Silent failures
- An unknown `estimator` string fell through an if/elseif chain into an undefined variable (`UndefVarError`); it now throws a clear `ArgumentError`.
- An unknown discretization `mode` silently fell back to `uniform_width` with a `println`; it now throws `ArgumentError`.

## 2. Breaking API change (issue [#9](https://github.com/Tchanders/InformationMeasures.jl/issues/9))

Per Julia naming conventions, the `get_` prefix is dropped from all public functions:

| Old | New |
|---|---|
| `get_entropy` | `entropy` |
| `get_probabilities` | `probabilities` |
| `get_conditional_entropy` | `conditional_entropy` |
| `get_mutual_information` | `mutual_information` |
| `get_conditional_mutual_information` | `conditional_mutual_information` |
| `get_interaction_information` | `interaction_information` |
| `get_total_correlation` | `total_correlation` |
| `get_partial_information_decomposition` | `partial_information_decomposition` |
| `get_redundancy` | `redundancy` |
| `get_cross_entropy` | `cross_entropy` |

The old `get_*` names remain as **deprecated aliases** (`Base.depwarn`) that return identical results, so existing user code keeps working with warnings. Suggested plan: remove the aliases in v0.5.

## 3. Test suite overhaul

- **`@testset` structure** — previously a single failure aborted everything with no per-test reporting.
- **Seeded RNG** (`MersenneTwister(42)`) — previously unseeded `rand` data made tests flaky and forced wide tolerances (up to `atol = 0.4`).
- **No shared state / ordering dependence** — the old suite explicitly required a specific include order.
- **Exact-value tests** on deterministic frequency tables, including asymmetric fixtures that would have caught the conditional-entropy direction bug.
- **New coverage:** estimator unit tests, error paths (`ArgumentError` for unknown estimator/mode), Bayesian blocks (previously commented out), the fallback-corruption regression test, cross-entropy asymmetry, and deprecation tests.
- **Result: 107/107 passing** on Julia 1.13.2.

## 4. Packaging

- Version bumped to **0.4.0**; compat updated to `julia = "1.6"`.
- README updated with an "Upgrading to v0.4" section listing every breaking change.
- `.gitignore` added; a `dev_test_environment/` scratch environment is included for local testing.
- **Not yet done (proposed next steps):** replace the dead Travis/AppVeyor configs with GitHub Actions CI, add Documenter.jl hosted docs, `CHANGELOG.md`, and `CITATION.cff`. Registration of v0.4.0 with the General registry should wait until this is merged upstream.

## 5. Open items for discussion

1. **API rename sign-off** — the `get_*` rename is the main breaking change; maintainer approval is sought before it goes upstream.
2. **Deprecation timeline** — proposal is to keep `get_*` aliases through v0.4 and remove in v0.5.
3. **Remaining open issues** — #25 (zero vectors break execution) and #26 (unsorted bin edges) are related to the discretization path fixed here but should be verified against the reporters' cases; #16 (comparison with PCA-CMI/PCA-PMI) is a research task, not addressed.
4. **Future features** (existing TODOs): dual total correlation, ΔI, >3-variable support in the measure functions (the frequency code already supports it), pre-computed shrinkage targets.
