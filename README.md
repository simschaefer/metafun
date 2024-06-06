
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

## Simulate Fixed-Effects model

Simulates data of multiple studies using predefined effect sizes and
between study heterogenity ($\tau$).

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         es_true = 0.7,
         es = 'SMD',
         fixed = TRUE,
         random = FALSE,
         varnames = c('x', 'y'))

head(sim$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se mean_x  mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.694 0.0415  0.708  0.0154 1.01  0.983  1234  1234 0.00172
#> 2     2    0.699 0.0394  0.704  0.0113 0.973 1.01   1364  1364 0.00156
#> 3     3    0.736 0.0330  0.725 -0.0206 1.02  1.01   1958  1958 0.00109
#> 4     4    0.691 0.0429  0.657 -0.0244 0.984 0.989  1150  1150 0.00184
#> 5     5    0.629 0.0888  0.655  0.0642 0.903 0.972   266   266 0.00789
#> 6     6    0.641 0.0513  0.684  0.0388 1.01  1.00    799   799 0.00263
```

# Effect size and standard error

``` r
require(tidyverse)
#> Loading required package: tidyverse
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.4     ✔ readr     2.1.4
#> ✔ forcats   1.0.0     ✔ stringr   1.5.0
#> ✔ ggplot2   3.4.4     ✔ tibble    3.2.1
#> ✔ lubridate 1.9.3     ✔ tidyr     1.3.0
#> ✔ purrr     1.0.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

ggplot(sim$data_aggr, aes(x = hedges_g, y = log(se), color = n_x))+
  geom_point(alpha = 0.5)+
  theme_minimal()+
  labs(x = "Effect Size (ES)",
       y = "log(SE)")+
  scale_color_viridis_c()
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" /> \#
Run Meta-Analysis

``` r
require(meta)
#> Loading required package: meta
#> Loading required package: metadat
#> Loading 'meta' package (version 7.0-0).
#> Type 'help(meta)' for a brief overview.
#> Readers of 'Meta-Analysis with R (Use R!)' should install
#> older version of 'meta' package: https://tinyurl.com/dt4y5drs

metaanalysis <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = sim$data_aggr %>% filter(study <= 10),
                 sm = "SMD",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis fixed-effect")

summary(metaanalysis)
#> Review:     Meta-Analysis fixed-effect
#> 
#>       SMD           95%-CI %W(common)
#> 1  0.6945 [0.6132; 0.7757]       12.1
#> 2  0.6992 [0.6219; 0.7765]       13.4
#> 3  0.7362 [0.6715; 0.8009]       19.1
#> 4  0.6910 [0.6069; 0.7752]       11.3
#> 5  0.6287 [0.4546; 0.8028]        2.6
#> 6  0.6414 [0.5408; 0.7419]        7.9
#> 7  0.7295 [0.6377; 0.8214]        9.5
#> 8  0.6779 [0.5088; 0.8471]        2.8
#> 9  0.7108 [0.6312; 0.7903]       12.6
#> 10 0.7017 [0.6057; 0.7977]        8.7
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z p-value
#> Common effect model 0.7023 [0.6740; 0.7306] 48.68       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0009]; tau = 0 [0.0000; 0.0292]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  3.72    9  0.9288
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
```

# Forest plot

``` r
forest(metaanalysis)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />
