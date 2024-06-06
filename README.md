
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metafun

<!-- badges: start -->
<!-- badges: end -->

metafun provides useful functions to teach and understand statistical
concept related to Meta-Analyses.

## Installation

You can install the development version of metafun from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("simschaefer/metafun")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(metafun)
## basic example code
```

## sim_meta

Simulates data of multiple studies using predefined effect sizes and
between study heterogenity ($\tau$).

``` r
df <- sim_meta(min_obs = 200,
         max_obs = 800,
         n_studies = 150,
         es_true = 0.7,
         es = 'SMD',
         fixed = TRUE,
         random = FALSE,
         varnames = c('x', 'y'))

head(df$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se  mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1   -0.717 0.0821  0.0589  0.778 1.06  0.943   316   316 0.00674
#> 2     2   -0.714 0.0567  0.0146  0.729 1.01  0.991   662   662 0.00321
#> 3     3   -0.684 0.0673 -0.0254  0.669 1.03  0.995   467   467 0.00453
#> 4     4   -0.795 0.0531 -0.0682  0.732 0.993 1.02    766   766 0.00282
#> 5     5   -0.626 0.0662  0.0413  0.651 1.00  0.946   479   479 0.00438
#> 6     6   -0.710 0.0590 -0.0476  0.663 0.987 1.01    611   611 0.00348
```
