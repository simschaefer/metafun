
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
#> 1     1    0.228 0.0439  0.0486   0.278 0.979 1.03   1046  1046 0.00192
#> 2     2    0.322 0.0322  0.0116   0.335 1.01  1.00   1958  1958 0.00103
#> 3     3    0.220 0.0440 -0.00439  0.225 1.03  1.06   1040  1040 0.00193
#> 4     4    0.261 0.0335 -0.0191   0.245 1.03  0.987  1802  1802 0.00112
#> 5     5    0.334 0.0327 -0.0268   0.310 1.01  1.00   1898  1898 0.00107
#> 6     6    0.324 0.0376 -0.0120   0.309 1.01  0.970  1436  1436 0.00141
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
#>       SMD            95%-CI %W(common)
#> 1  0.2277 [ 0.1417; 0.3137]        9.6
#> 2  0.3219 [ 0.2588; 0.3849]       17.8
#> 3  0.2199 [ 0.1337; 0.3062]        9.5
#> 4  0.2610 [ 0.1954; 0.3265]       16.5
#> 5  0.3337 [ 0.2696; 0.3977]       17.2
#> 6  0.3239 [ 0.2502; 0.3975]       13.1
#> 7  0.4734 [ 0.2297; 0.7170]        1.2
#> 8  0.3474 [ 0.2639; 0.4309]       10.1
#> 9  0.3017 [ 0.1730; 0.4304]        4.3
#> 10 0.0886 [-0.2140; 0.3912]        0.8
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2972 [0.2706; 0.3238] 21.90 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0008 [0.0000; 0.0195]; tau = 0.0291 [0.0000; 0.1397]
#>  I^2 = 37.2% [0.0%; 70.1%]; H = 1.26 [1.00; 1.83]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  14.33    9  0.1110
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
#>   study hedges_g     se  mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.739 0.0407 -0.0268  0.703 1.01  0.964  1288  1288 0.00166
#> 2     2    0.707 0.0501 -0.0305  0.686 1.03  0.997   845   845 0.00251
#> 3     3    0.647 0.0468  0.0517  0.694 0.972 1.01    961   961 0.00219
#> 4     4    0.756 0.0330 -0.0461  0.711 1.01  0.992  1963  1963 0.00109
#> 5     5    0.575 0.0495  0.0235  0.603 0.995 1.02    851   851 0.00245
#> 6     6    0.830 0.160  -0.0178  0.778 0.992 0.915    85    85 0.0256
```

Run Random-Effects Meta-Analysis

``` r
require(meta)
require(metafor)

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
#> 1  0.7394 [0.6596; 0.8192]       11.6
#> 2  0.7067 [0.6084; 0.8049]       10.5
#> 3  0.6469 [0.5552; 0.7386]       10.9
#> 4  0.7565 [0.6917; 0.8212]       12.4
#> 5  0.5745 [0.4776; 0.6715]       10.6
#> 6  0.8304 [0.5170; 1.1437]        3.1
#> 7  0.7431 [0.6656; 0.8206]       11.7
#> 8  0.4979 [0.4180; 0.5778]       11.6
#> 9  0.7833 [0.6744; 0.8921]        9.9
#> 10 0.7719 [0.6221; 0.9217]        7.8
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6928 [0.6210; 0.7645] 21.84 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0071 [0.0022; 0.0304]; tau = 0.0841 [0.0466; 0.1744]
#>  I^2 = 77.9% [59.5%; 87.9%]; H = 2.13 [1.57; 2.87]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  40.66    9 < 0.0001
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Paule-Mandel estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)


metafor::forest(metaanalysis, header = TRUE)
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
