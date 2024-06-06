
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
         n_studies = 20,
         es_true = 0.3,
         es = 'SMD',
         fixed = TRUE,
         random = FALSE,
         varnames = c('x', 'y'))

head(sim$data_aggr)
#> # A tibble: 6 × 10
#>   study hedges_g     se mean_x  mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1   0.290  0.0367  0.315  0.0235 1.01  0.998  1497  1497 0.00135
#> 2     2   0.303  0.0419  0.274 -0.0308 0.999 1.01   1153  1153 0.00175
#> 3     3   0.316  0.0356  0.282 -0.0336 0.974 1.02   1599  1599 0.00127
#> 4     4   0.257  0.0326  0.310  0.0531 1.00  0.991  1892  1892 0.00107
#> 5     5   0.379  0.0765  0.337 -0.0251 0.942 0.968   348   348 0.00585
#> 6     6   0.0360 0.142   0.210  0.173  0.965 1.06     99    99 0.0202
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
#> 1  0.2898 [ 0.2178; 0.3619]       16.7
#> 2  0.3034 [ 0.2213; 0.3855]       12.8
#> 3  0.3162 [ 0.2465; 0.3860]       17.8
#> 4  0.2572 [ 0.1932; 0.3212]       21.1
#> 5  0.3790 [ 0.2291; 0.5289]        3.8
#> 6  0.0360 [-0.2426; 0.3146]        1.1
#> 7  0.3045 [ 0.2036; 0.4055]        8.5
#> 8  0.3499 [ 0.2241; 0.4756]        5.5
#> 9  0.3135 [ 0.1990; 0.4281]        6.6
#> 10 0.2773 [ 0.1581; 0.3964]        6.1
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2953 [0.2659; 0.3247] 19.68 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0135]; tau = 0.0004 [0.0000; 0.1163]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  7.23    9  0.6129
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
#>   study hedges_g     se mean_x   mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.691 0.0374  0.703  0.00805 1.02  0.993  1518  1518 0.00140
#> 2     2    0.749 0.0984  0.660 -0.0557  0.942 0.967   221   221 0.00968
#> 3     3    0.790 0.0523  0.710 -0.0910  1.01  1.01    788   788 0.00274
#> 4     4    0.534 0.0325  0.667  0.137   0.978 1.01   1963  1963 0.00106
#> 5     5    0.679 0.0404  0.658 -0.0215  1.02  0.976  1299  1299 0.00163
#> 6     6    0.733 0.0355  0.683 -0.0369  0.972 0.994  1697  1697 0.00126
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
#> 1  0.6907 [0.6175; 0.7640]       11.6
#> 2  0.7490 [0.5561; 0.9419]        5.8
#> 3  0.7898 [0.6873; 0.8923]       10.0
#> 4  0.5339 [0.4703; 0.5976]       12.1
#> 5  0.6789 [0.5998; 0.7580]       11.3
#> 6  0.7327 [0.6631; 0.8022]       11.8
#> 7  0.8663 [0.7527; 0.9800]        9.4
#> 8  0.6534 [0.5620; 0.7448]       10.6
#> 9  0.8236 [0.7325; 0.9147]       10.7
#> 10 0.7161 [0.5427; 0.8894]        6.6
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7170 [0.6468; 0.7872] 23.10 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0069 [0.0023; 0.0274]; tau = 0.0830 [0.0482; 0.1656]
#>  I^2 = 80.7% [65.5%; 89.2%]; H = 2.28 [1.70; 3.05]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  46.71    9 < 0.0001
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)

metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
