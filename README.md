
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
#> 1     1    0.365 0.0457 -0.0101   0.359 1.00  1.02    975   975 0.00209
#> 2     2    0.280 0.0392  0.0250   0.306 0.991 1.02   1317  1317 0.00153
#> 3     3    0.298 0.0334  0.00602  0.305 1.01  0.999  1817  1817 0.00111
#> 4     4    0.293 0.0393 -0.00129  0.301 1.04  1.02   1309  1309 0.00154
#> 5     5    0.300 0.0420 -0.00234  0.300 1.01  1.00   1147  1147 0.00176
#> 6     6    0.427 0.0618 -0.0634   0.365 1.00  0.998   535   535 0.00382
```

# Effect size and standard error

``` r
require(tidyverse)

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
#> 1  0.3650 [0.2755; 0.4545]        9.5
#> 2  0.2803 [0.2036; 0.3571]       12.9
#> 3  0.2976 [0.2322; 0.3630]       17.8
#> 4  0.2932 [0.2162; 0.3702]       12.8
#> 5  0.2997 [0.2174; 0.3820]       11.2
#> 6  0.4273 [0.3061; 0.5485]        5.2
#> 7  0.4045 [0.2689; 0.5402]        4.1
#> 8  0.2634 [0.1792; 0.3475]       10.7
#> 9  0.3115 [0.2283; 0.3947]       11.0
#> 10 0.3772 [0.2514; 0.5030]        4.8
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3142 [0.2867; 0.3418] 22.34 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0077]; tau = 0.0011 [0.0000; 0.0878]
#>  I^2 = 10.5% [0.0%; 51.0%]; H = 1.06 [1.00; 1.43]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  10.06    9  0.3459
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
#> 1     1    0.815 0.0433 -0.0621   0.749 1.00  0.990  1155  1155 0.00188
#> 2     2    0.582 0.0795  0.0749   0.686 1.10  1.00    330   330 0.00632
#> 3     3    0.680 0.0623 -0.0652   0.640 1.06  1.02    545   545 0.00388
#> 4     4    0.717 0.0381 -0.00661  0.715 1.01  1.00   1468  1468 0.00145
#> 5     5    0.511 0.0384  0.107    0.622 0.993 1.02   1401  1401 0.00147
#> 6     6    0.734 0.0364  0.0545   0.784 0.991 0.995  1613  1613 0.00132
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
#> 1  0.8148 [0.7299; 0.8997]       11.1
#> 2  0.5816 [0.4258; 0.7374]        7.4
#> 3  0.6802 [0.5581; 0.8023]        9.1
#> 4  0.7171 [0.6424; 0.7917]       11.6
#> 5  0.5111 [0.4358; 0.5863]       11.6
#> 6  0.7344 [0.6631; 0.8057]       11.8
#> 7  0.6044 [0.4824; 0.7264]        9.1
#> 8  0.6849 [0.5821; 0.7876]       10.1
#> 9  0.8166 [0.7328; 0.9004]       11.1
#> 10 0.7004 [0.5383; 0.8626]        7.2
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6891 [0.6172; 0.7609] 21.69 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0073 [0.0024; 0.0292]; tau = 0.0852 [0.0491; 0.1710]
#>  I^2 = 79.8% [63.5%; 88.8%]; H = 2.22 [1.65; 2.98]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  44.45    9 < 0.0001
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)


metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
