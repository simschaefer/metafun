
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
         smd_true = 0.3,
         r_true = 0,
         es = 'SMD',
         random = FALSE)

head(sim)
#> # A tibble: 6 × 10
#>   study hedges_g     se   mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>    <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.344 0.0436 -0.00709  0.329 0.974 0.979  1069  1069 0.00190
#> 2     2    0.338 0.0367  0.00981  0.349 0.963 1.05   1508  1508 0.00135
#> 3     3    0.511 0.103  -0.0803   0.451 1.01  1.07    195   195 0.0106 
#> 4     4    0.290 0.0401  0.0438   0.333 0.983 1.01   1257  1257 0.00161
#> 5     5    0.309 0.0631 -0.0278   0.287 1.05  0.991   509   509 0.00398
#> 6     6    0.249 0.0442  0.0173   0.272 1.04  1.00   1032  1032 0.00195
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

ggplot(sim, aes(x = hedges_g, y = log(se), color = n_x))+
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
                 data = sim %>% filter(study <= 10),
                 sm = "SMD",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis fixed-effect")

summary(metaanalysis)
#> Review:     Meta-Analysis fixed-effect
#> 
#>       SMD           95%-CI %W(common)
#> 1  0.3443 [0.2589; 0.4297]        9.8
#> 2  0.3377 [0.2658; 0.4096]       13.9
#> 3  0.5111 [0.3094; 0.7128]        1.8
#> 4  0.2896 [0.2110; 0.3682]       11.6
#> 5  0.3086 [0.1850; 0.4322]        4.7
#> 6  0.2487 [0.1620; 0.3353]        9.6
#> 7  0.2819 [0.2142; 0.3497]       15.6
#> 8  0.2188 [0.1030; 0.3347]        5.3
#> 9  0.3389 [0.2750; 0.4027]       17.6
#> 10 0.2473 [0.1629; 0.3318]       10.1
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3020 [0.2752; 0.3288] 22.09 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0002 [0.0000; 0.0151]; tau = 0.0156 [0.0000; 0.1230]
#>  I^2 = 29.6% [0.0%; 66.3%]; H = 1.19 [1.00; 1.72]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  12.79    9  0.1725
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
```

# Forest plot

``` r
metafor::forest(metaanalysis,
             sortvar = TE,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "g", "SE"))
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" /> \#
Simulate Random-Effects model

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         smd_true = 0.7,
         es = 'SMD',
         random = TRUE,
         tau = 0.05)

head(sim)
#> # A tibble: 6 × 10
#>   study hedges_g     se   mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>    <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.704 0.0347  0.0320   0.734 0.971 1.02   1760  1760 0.00121
#> 2     2    0.627 0.0357 -0.00514  0.632 1.00  1.03   1649  1649 0.00127
#> 3     3    0.666 0.0399  0.00806  0.666 0.991 0.984  1324  1324 0.00159
#> 4     4    0.599 0.0362  0.0108   0.608 0.985 1.01   1592  1592 0.00131
#> 5     5    0.693 0.0969  0.0329   0.755 1.05  1.03    226   226 0.00938
#> 6     6    0.708 0.0838  0.0131   0.735 1.01  1.02    303   303 0.00701
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
                 data = sim %>% filter(study <= 10),
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
#> 1  0.7037 [0.6356; 0.7718]       13.9
#> 2  0.6266 [0.5567; 0.6965]       13.7
#> 3  0.6659 [0.5876; 0.7441]       12.8
#> 4  0.5988 [0.5278; 0.6698]       13.5
#> 5  0.6929 [0.5030; 0.8827]        5.0
#> 6  0.7079 [0.5438; 0.8721]        6.2
#> 7  0.7250 [0.6153; 0.8348]        9.8
#> 8  0.7678 [0.6891; 0.8465]       12.7
#> 9  0.7661 [0.3789; 1.1533]        1.5
#> 10 0.8610 [0.7642; 0.9578]       10.9
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7023 [0.6447; 0.7598] 27.61 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0034 [0.0007; 0.0162]; tau = 0.0587 [0.0265; 0.1274]
#>  I^2 = 65.8% [33.0%; 82.5%]; H = 1.71 [1.22; 2.39]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  26.31    9  0.0018
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)


metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
