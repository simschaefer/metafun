
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

head(sim$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se mean_x   mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.271 0.0321  0.269  0.00563 0.973 0.973  1956  1956 0.00103
#> 2     2    0.310 0.0389  0.271 -0.0423  0.991 1.02   1337  1337 0.00151
#> 3     3    0.319 0.0368  0.335  0.00743 1.04  1.02   1498  1498 0.00135
#> 4     4    0.359 0.0579  0.331 -0.0203  0.967 0.984   606   606 0.00335
#> 5     5    0.292 0.0614  0.260 -0.0251  0.977 0.979   536   536 0.00377
#> 6     6    0.309 0.0614  0.362  0.0519  1.01  0.999   536   536 0.00378
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
#> 1  0.2706 [0.2077; 0.3336]       21.9
#> 2  0.3105 [0.2342; 0.3867]       14.9
#> 3  0.3190 [0.2469; 0.3911]       16.7
#> 4  0.3595 [0.2460; 0.4730]        6.7
#> 5  0.2918 [0.1714; 0.4122]        6.0
#> 6  0.3091 [0.1886; 0.4295]        6.0
#> 7  0.2529 [0.0098; 0.4960]        1.5
#> 8  0.3435 [0.2483; 0.4387]        9.6
#> 9  0.3327 [0.2469; 0.4184]       11.8
#> 10 0.2958 [0.1619; 0.4297]        4.8
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3095 [0.2800; 0.3390] 20.58 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0004]; tau = 0 [0.0000; 0.0206]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  3.38    9  0.9474
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

head(sim$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se mean_x  mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.770 0.0332  0.740 -0.0163 0.974 0.991  1951  1951 0.00110
#> 2     2    0.711 0.0519  0.694 -0.0202 0.997 1.01    789   789 0.00270
#> 3     3    1.02  0.217   0.868  0.0541 0.701 0.869    48    48 0.0471 
#> 4     4    0.712 0.0361  0.674 -0.0320 0.971 1.01   1636  1636 0.00130
#> 5     5    0.756 0.0780  0.721 -0.0444 1.02  1.00    352   352 0.00609
#> 6     6    0.294 0.244   0.309  0.0369 0.828 0.995    34    34 0.0595
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
#>       SMD            95%-CI %W(random)
#> 1  0.7701 [ 0.7050; 0.8351]       24.5
#> 2  0.7113 [ 0.6096; 0.8131]       10.0
#> 3  1.0232 [ 0.5977; 1.4486]        0.6
#> 4  0.7125 [ 0.6418; 0.7831]       20.7
#> 5  0.7555 [ 0.6026; 0.9084]        4.4
#> 6  0.2937 [-0.1842; 0.7716]        0.5
#> 7  0.6577 [ 0.5058; 0.8096]        4.5
#> 8  0.7233 [ 0.5962; 0.8503]        6.4
#> 9  0.7326 [ 0.6168; 0.8484]        7.7
#> 10 0.7011 [ 0.6304; 0.7719]       20.7
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7257 [0.6898; 0.7616] 45.72 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0521]; tau = 0 [0.0000; 0.2283]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  8.41    9  0.4933
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)

metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
