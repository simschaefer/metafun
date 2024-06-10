
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
#>   study hedges_g     se mean_x    mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>     <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.251 0.0441  0.267  0.0193   1.01  0.972  1036  1036 0.00195
#> 2     2    0.314 0.0394  0.301 -0.0151   1.01  1.01   1303  1303 0.00155
#> 3     3    0.363 0.0491  0.332 -0.0230   0.999 0.955   844   844 0.00241
#> 4     4    0.276 0.0424  0.305  0.0230   1.03  1.02   1125  1125 0.00179
#> 5     5    0.221 0.0956  0.287  0.0723   0.940 0.996   220   220 0.00915
#> 6     6    0.314 0.217   0.306 -0.000287 0.916 1.02     43    43 0.0471
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
#>       SMD            95%-CI %W(common)
#> 1  0.2506 [ 0.1642; 0.3371]       10.3
#> 2  0.3143 [ 0.2371; 0.3916]       12.9
#> 3  0.3635 [ 0.2673; 0.4596]        8.3
#> 4  0.2756 [ 0.1926; 0.3586]       11.1
#> 5  0.2214 [ 0.0339; 0.4088]        2.2
#> 6  0.3137 [-0.1116; 0.7390]        0.4
#> 7  0.3791 [ 0.2724; 0.4857]        6.8
#> 8  0.2892 [ 0.2240; 0.3544]       18.1
#> 9  0.3581 [ 0.2765; 0.4397]       11.5
#> 10 0.3519 [ 0.2874; 0.4165]       18.4
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3173 [0.2896; 0.3450] 22.44 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0002 [0.0000; 0.0055]; tau = 0.0138 [0.0000; 0.0744]
#>  I^2 = 2.4% [0.0%; 63.3%]; H = 1.01 [1.00; 1.65]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  9.22    9  0.4175
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
#>   study hedges_g     se mean_x  mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.709 0.0411  0.674 -0.0323 0.988 1.00   1261  1261 0.00169
#> 2     2    0.662 0.132   0.795  0.143  0.911 1.05    121   121 0.0174 
#> 3     3    0.682 0.0458  0.666 -0.0253 1.02  1.01   1007  1007 0.00210
#> 4     4    0.790 0.0841  0.797  0.0198 1.00  0.967   305   305 0.00707
#> 5     5    0.681 0.0437  0.724  0.0499 1.01  0.974  1110  1110 0.00191
#> 6     6    0.443 0.0981  0.558  0.117  1.03  0.960   213   213 0.00962
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
#> 1  0.7086 [0.6281; 0.7890]       13.6
#> 2  0.6623 [0.4035; 0.9211]        5.1
#> 3  0.6824 [0.5926; 0.7723]       13.1
#> 4  0.7896 [0.6248; 0.9543]        8.7
#> 5  0.6813 [0.5958; 0.7669]       13.3
#> 6  0.4432 [0.2510; 0.6355]        7.4
#> 7  0.6070 [0.4834; 0.7306]       11.0
#> 8  0.8226 [0.7501; 0.8951]       14.1
#> 9  0.4994 [0.2796; 0.7191]        6.4
#> 10 0.5657 [0.3702; 0.7613]        7.3
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6677 [0.5863; 0.7492] 18.55 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0078 [0.0012; 0.0407]; tau = 0.0885 [0.0353; 0.2019]
#>  I^2 = 66.2% [33.9%; 82.7%]; H = 1.72 [1.23; 2.40]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  26.60    9  0.0016
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)

metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
