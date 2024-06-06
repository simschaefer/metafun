
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
#>   study hedges_g     se mean_x   mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.817 0.0466  0.758 -0.0605  0.970 1.03   1000  1000 0.00217
#> 2     2    0.671 0.0641  0.728  0.0571  1.01  0.991   514   514 0.00411
#> 3     3    0.723 0.0332  0.704 -0.00956 0.984 0.988  1936  1936 0.00110
#> 4     4    0.680 0.0356  0.655 -0.0177  0.990 0.987  1674  1674 0.00126
#> 5     5    0.640 0.0354  0.697  0.0644  0.997 0.978  1682  1682 0.00125
#> 6     6    0.723 0.112   0.772  0.0265  1.05  1.01    171   171 0.0125
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
#> 1  0.8174 [0.7262; 0.9086]        9.8
#> 2  0.6706 [0.5450; 0.7963]        5.2
#> 3  0.7232 [0.6582; 0.7882]       19.3
#> 4  0.6802 [0.6105; 0.7498]       16.8
#> 5  0.6404 [0.5711; 0.7097]       17.0
#> 6  0.7227 [0.5040; 0.9415]        1.7
#> 7  0.7278 [0.6298; 0.8258]        8.5
#> 8  0.8572 [0.5502; 1.1642]        0.9
#> 9  0.6227 [0.5411; 0.7042]       12.3
#> 10 0.7110 [0.6142; 0.8078]        8.7
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z p-value
#> Common effect model 0.6966 [0.6681; 0.7252] 47.82       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0017 [0.0000; 0.0109]; tau = 0.0413 [0.0000; 0.1046]
#>  I^2 = 40.1% [0.0%; 71.4%]; H = 1.29 [1.00; 1.87]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  15.01    9  0.0905
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
#> 1     1    0.692 0.0368  0.766  0.0731 1.02  0.984  1562  1562 0.00136
#> 2     2    0.810 0.0549  0.713 -0.0802 0.993 0.964   717   717 0.00302
#> 3     3    0.738 0.0344  0.668 -0.0818 1.03  1.00   1807  1807 0.00118
#> 4     4    0.841 0.0468  0.775 -0.0366 0.946 0.984   992   992 0.00219
#> 5     5    0.692 0.0433  0.648 -0.0452 0.973 1.03   1133  1133 0.00187
#> 6     6    0.700 0.0780  0.750  0.0648 1.00  0.955   349   349 0.00608
```

Run Random-Effects Meta-Analysis

``` r
require(meta)

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
#> 1  0.6921 [0.6199; 0.7643]       13.9
#> 2  0.8099 [0.7023; 0.9176]        8.9
#> 3  0.7384 [0.6710; 0.8058]       14.8
#> 4  0.8408 [0.7490; 0.9326]       10.8
#> 5  0.6921 [0.6073; 0.7769]       11.8
#> 6  0.7000 [0.5471; 0.8528]        5.3
#> 7  0.7420 [0.6708; 0.8132]       14.1
#> 8  0.6451 [0.5714; 0.7188]       13.7
#> 9  0.8325 [0.5407; 1.1244]        1.7
#> 10 0.7927 [0.6330; 0.9524]        5.0
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7339 [0.6881; 0.7797] 36.25 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0016 [0.0000; 0.0111]; tau = 0.0396 [0.0000; 0.1053]
#>  I^2 = 43.8% [0.0%; 73.1%]; H = 1.33 [1.00; 1.93]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  16.02    9  0.0665
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)

forest(metaanalysis)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
