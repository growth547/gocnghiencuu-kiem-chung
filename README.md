# Góc Nghiên Cứu: validation of free browser-based statistics tools

Góc Nghiên Cứu (https://gocnghiencuu.com, English edition https://gocnghiencuu.com/en/) offers free, no-sign-up tools for quantitative theses: Cronbach's alpha, exploratory factor analysis, regression, t-test and ANOVA, PLS-SEM, CB-SEM, sample size, mediation and moderation, chi-square, logistic regression and more. Calculations run in the browser; survey data is not uploaded.

This repository holds the evidence that those tools give the same numbers as established R packages, so anyone can rerun the comparison.

## What is compared

`results/kiem-chung.json`: 666 values, each computed by the tool and by the reference implementation on the same public data.

| Tool | Reference | Values compared | Largest absolute difference |
|---|---|---|---|
| Cronbach's alpha, item-total statistics | `psych::alpha` | 92 | 5 × 10⁻¹¹ |
| EFA (SPSS defaults: PAF, varimax / promax), KMO, Bartlett | `EFAtools::EFA(type = "SPSS")`, `psych::KMO`, `psych::cortest.bartlett` | 124 | 2.4 × 10⁻⁴ |
| Multiple regression | `stats::lm` | 30 | 5 × 10⁻¹¹ |
| t-test, ANOVA, Levene | `stats::t.test`, `stats::oneway.test` | 14 | 5 × 10⁻¹¹ |
| PLS-SEM (path weighting) | `seminr::estimate_pls` | 84 | 5 × 10⁻¹¹ |
| Sample size (noncentral F, G*Power method; inverse square root) | base R | 36 | 0 |
| CB-SEM (CFA on Holzinger–Swineford, ECSI model on mobi) | `lavaan` (`reference/cbsem_reference.R`) | 286 | 1.1 × 10⁻⁵ |

Versions used: R 4.6.1, psych 2.6.9, lavaan 0.7.3, seminr 2.6.0, EFAtools 1.1.0 (see `results/kiem-chung.json`). Human-readable report: https://gocnghiencuu.com/en/verification/ (Vietnamese: https://gocnghiencuu.com/kiem-chung/).

## Data

`data/` contains the public data sets the comparison runs on, as shipped with their R packages:

- `bfi.csv`: 2,800 people, 25 Big Five items (`psych::bfi`, Revelle, SAPA project)
- `holzinger-swineford-1939.csv`: 301 pupils, 9 ability tests (`lavaan::HolzingerSwineford1939`)
- `mobi.csv`: 250 mobile-phone customers, ECSI model (`seminr::mobi`, Tenenhaus et al., 2005)

## Rerun

```r
install.packages(c("psych", "lavaan", "semTools", "seminr", "EFAtools", "GPArotation", "jsonlite"))
```

```bash
Rscript reference/kiem_chung_reference.R
Rscript reference/cbsem_reference.R
```

The scripts write the reference values; compare them with the `ref` fields in `results/kiem-chung.json`.

## Scale library metadata

`scale-library/` holds metadata for the 121 measurement scales documented at https://gocnghiencuu.com/thang-do/ (constructs, item counts, response formats, sources with DOIs, published reliability values). Item wording is not included because it belongs to the scales' original authors; see `scale-library/README.md`.

## Report a discrepancy

Open an issue with the data, the tool, and the value you expected (and the software that produced it), or use the feedback box on https://gocnghiencuu.com/kiem-chung/.

## Licence

Code: MIT. Results and scale metadata: CC BY 4.0. Data sets in `data/` keep the licences of the R packages they come from.

## Citation

See `CITATION.cff`, or: Ban biên tập Góc Nghiên Cứu (2026). *Góc Nghiên Cứu: validation of free browser-based statistics tools against R* (Version 1.0.0) [Computer software]. https://github.com/growth547/gocnghiencuu-kiem-chung
