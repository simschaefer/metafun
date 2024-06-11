
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metafun

<!-- badges: start -->
<!-- badges: end -->

‘metafun’ offers valuable functions for teaching and understanding
statistical concepts related to meta-analyses using a simulation-based
approach. Please note that this package is currently under development,
and full functionality is not yet available.

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
         es_true = 0.3,
         es = 'SMD',
         fixed = TRUE,
         random = FALSE,
         varnames = c('x', 'y'))
#> Warning in sim_meta(min_obs = 20, max_obs = 2000, n_studies = 1500, es_true =
#> 0.3, : Number of moderator labels (0) does not match the number of effect sizes
#> (1). Only the first -1 effect sizes are used.

head(sim$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se mean_x   mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.269 0.0499  0.278  0.00232 1.03  1.03    809   809 0.00249
#> 2     2    0.284 0.0368  0.302  0.0217  0.997 0.977  1492  1492 0.00135
#> 3     3    0.254 0.0554  0.290  0.0353  1.01  0.988   658   658 0.00306
#> 4     4    0.331 0.0325  0.322 -0.00239 0.972 0.989  1918  1918 0.00106
#> 5     5    0.351 0.110   0.368  0.0185  0.970 1.02    169   169 0.0120 
#> 6     6    0.351 0.0405  0.351 -0.00456 1.04  0.982  1241  1241 0.00164
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

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

# Run Meta-Analysis on simulated data

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
#> 1  0.2685 [0.1706; 0.3664]        6.6
#> 2  0.2843 [0.2122; 0.3564]       12.2
#> 3  0.2545 [0.1460; 0.3630]        5.4
#> 4  0.3312 [0.2675; 0.3950]       15.7
#> 5  0.3510 [0.1362; 0.5659]        1.4
#> 6  0.3511 [0.2718; 0.4304]       10.1
#> 7  0.3260 [0.2594; 0.3925]       14.4
#> 8  0.3006 [0.2319; 0.3693]       13.5
#> 9  0.3275 [0.2553; 0.3997]       12.2
#> 10 0.2610 [0.1742; 0.3478]        8.4
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3082 [0.2829; 0.3334] 23.94 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0020]; tau = 0 [0.0000; 0.0444]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  5.51    9  0.7880
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

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" /> \#
Simulate Random-Effects model

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         es_true = 0.7,
         es = 'SMD',
         fixed = FALSE,
         random = TRUE,
         tau = 0.05,
         varnames = c('x', 'y'))
#> Warning in sim_meta(min_obs = 20, max_obs = 2000, n_studies = 1500, es_true =
#> 0.7, : Number of moderator labels (0) does not match the number of effect sizes
#> (1). Only the first -1 effect sizes are used.

head(sim$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se mean_x    mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>     <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.639 0.0394  0.634 -0.000413 0.978 1.01   1356  1356 0.00155
#> 2     2    0.763 0.0856  0.711 -0.0368   0.974 0.984   293   293 0.00732
#> 3     3    0.664 0.0352  0.651 -0.00905  0.992 0.996  1707  1707 0.00124
#> 4     4    0.698 0.0388  0.690 -0.0183   1.06  0.965  1409  1409 0.00151
#> 5     5    0.653 0.0561  0.689  0.0411   0.991 0.992   670   670 0.00314
#> 6     6    0.847 0.0519  0.717 -0.136    0.997 1.02    809   809 0.00269
```

Run Random-Effects Meta-Analysis

``` r
require(meta)
require(metafor)
#> Loading required package: metafor
#> Loading required package: Matrix
#> 
#> Attaching package: 'Matrix'
#> The following objects are masked from 'package:tidyr':
#> 
#>     expand, pack, unpack
#> Loading required package: numDeriv
#> 
#> Loading the 'metafor' package (version 4.4-0). For an
#> introduction to the package please type: help(metafor)

metaanalysis <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = sim$data_aggr %>% filter(study <= 10),
                 sm = "SMD",
                 fixed = FALSE,
                 random = TRUE,
                 method.tau = 'PM',
                 method.random.ci = "HK",
                 title = "Meta-Analysis fixed-effect")

summary(metaanalysis)
#> Review:     Meta-Analysis fixed-effect
#> 
#>       SMD           95%-CI %W(random)
#> 1  0.6385 [0.5613; 0.7157]       12.2
#> 2  0.7631 [0.5954; 0.9308]        5.4
#> 3  0.6636 [0.5947; 0.7325]       13.1
#> 4  0.6978 [0.6218; 0.7739]       12.3
#> 5  0.6528 [0.5429; 0.7627]        9.0
#> 6  0.8465 [0.7448; 0.9482]        9.8
#> 7  0.6037 [0.4995; 0.7078]        9.5
#> 8  0.5497 [0.3636; 0.7359]        4.6
#> 9  0.6381 [0.5582; 0.7179]       11.9
#> 10 0.7040 [0.6262; 0.7819]       12.1
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6779 [0.6243; 0.7314] 28.62 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0030 [0.0000; 0.0187]; tau = 0.0551 [0.0000; 0.1368]
#>  I^2 = 50.9% [0.0%; 76.1%]; H = 1.43 [1.00; 2.05]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  18.33    9  0.0315
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)


metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
