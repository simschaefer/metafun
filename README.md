
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

Load package in R:

``` r
require(metafun)
#> Loading required package: metafun
```

# Standardized Mean Differences

## Fixed Effect Model

### Simulate data

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
#>   study hedges_g     se    mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>     <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.341 0.0358 -0.000963  0.337 0.996 0.984  1587  1587 0.00128
#> 2     2    0.280 0.0321 -0.00530   0.272 0.999 0.985  1957  1957 0.00103
#> 3     3    0.228 0.0890  0.116     0.344 0.976 1.02    254   254 0.00793
#> 4     4    0.377 0.0885 -0.0235    0.347 0.977 0.984   260   260 0.00783
#> 5     5    0.317 0.0448 -0.0262    0.293 1.04  0.970  1007  1007 0.00201
#> 6     6    0.300 0.0344  0.00820   0.307 1.00  0.985  1706  1706 0.00119
```

### Effect size and standard error

``` r
require(tidyverse)

ggplot(sim, aes(x = hedges_g, y = log(se), color = n_x))+
  geom_point(alpha = 0.5)+
  theme_minimal()+
  labs(x = "Effect Size (ES)",
       y = "log(SE)")+
  scale_color_viridis_c()
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

### Run Meta-Analysis on simulated data

``` r
require(meta)

# choose only studies 1-10 for better readability
analysis_data <- sim %>% 
  filter(study <= 10)

meta_fixed <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = analysis_data,
                 sm = "SMD",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis Fixed effect")

summary(meta_fixed)
#> Review:     Meta-Analysis Fixed effect
#> 
#>       SMD           95%-CI %W(common)
#> 1  0.3410 [0.2709; 0.4111]       13.9
#> 2  0.2798 [0.2168; 0.3427]       17.2
#> 3  0.2282 [0.0537; 0.4027]        2.2
#> 4  0.3771 [0.2037; 0.5505]        2.3
#> 5  0.3172 [0.2293; 0.4051]        8.8
#> 6  0.3004 [0.2329; 0.3679]       15.0
#> 7  0.2835 [0.2173; 0.3496]       15.6
#> 8  0.1442 [0.0201; 0.2683]        4.4
#> 9  0.3230 [0.1960; 0.4499]        4.2
#> 10 0.2808 [0.2159; 0.3456]       16.2
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2923 [0.2662; 0.3184] 21.92 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0092]; tau = 0.0005 [0.0000; 0.0960]
#>  I^2 = 7.1% [0.0%; 65.0%]; H = 1.04 [1.00; 1.69]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  9.69    9  0.3764
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
```

### Forest plot

``` r
metafor::forest(meta_fixed,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "g", "SE"))
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## Random-Effects model Standardized Mean Difference

### Simulate data

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
#> 1     1    0.700 0.0643 -0.0880  0.614 0.996 1.01    514   514 0.00413
#> 2     2    0.964 0.0511 -0.125   0.819 0.950 1.01    855   855 0.00261
#> 3     3    0.617 0.0671  0.0493  0.649 0.974 0.968   466   466 0.00450
#> 4     4    0.714 0.114   0.0197  0.728 0.933 1.04    165   165 0.0129 
#> 5     5    0.622 0.0376  0.0228  0.642 1.02  0.974  1485  1485 0.00141
#> 6     6    0.627 0.127  -0.0163  0.602 0.914 1.05    130   130 0.0161
```

### Run Meta-Analysis on simulated data

``` r
require(meta)
require(metafor)

# choose only studies 1-10 for better readability
analysis_data <- sim %>% 
  filter(study <= 10)

meta_random <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = analysis_data,
                 sm = "SMD",
                 fixed = FALSE,
                 random = TRUE,
                 method.tau = 'REML',
                 method.random.ci = "HK",
                 title = "Meta-Analysis Random Effects")

summary(meta_random)
#> Review:     Meta-Analysis Random Effects
#> 
#>       SMD           95%-CI %W(random)
#> 1  0.7002 [0.5743; 0.8262]       11.0
#> 2  0.9644 [0.8642; 1.0645]       12.1
#> 3  0.6174 [0.4859; 0.7488]       10.7
#> 4  0.7139 [0.4913; 0.9364]        7.2
#> 5  0.6217 [0.5481; 0.6954]       13.1
#> 6  0.6270 [0.3780; 0.8760]        6.4
#> 7  0.7766 [0.7014; 0.8518]       13.0
#> 8  0.6516 [0.5092; 0.7940]       10.3
#> 9  0.4453 [0.0999; 0.7907]        4.2
#> 10 0.8394 [0.7366; 0.9421]       12.0
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7201 [0.6248; 0.8154] 17.09 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0126 [0.0035; 0.0560]; tau = 0.1123 [0.0592; 0.2366]
#>  I^2 = 78.8% [61.5%; 88.3%]; H = 2.17 [1.61; 2.93]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  42.52    9 < 0.0001
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)


metafor::forest(meta_random,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "g", "SE"))
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

# Correlations

## Fixed Effect Model

### Simulate data

Simulates data of multiple studies using predefined effect sizes and
between study heterogenity ($\tau$).

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         smd_true = 0,
         r_true = 0.5,
         es = 'ZCOR',
         random = FALSE)

head(sim)
#> # A tibble: 6 × 5
#>   study     z     r     n     se
#>   <int> <dbl> <dbl> <int>  <dbl>
#> 1     1 0.562 0.509  1447 0.0263
#> 2     2 0.554 0.503   535 0.0434
#> 3     3 0.501 0.463  1056 0.0308
#> 4     4 0.534 0.489   897 0.0334
#> 5     5 0.647 0.570    45 0.154 
#> 6     6 0.611 0.545  1186 0.0291
```

### Run Meta-Analysis on simulated data

``` r
require(meta)

# choose only studies 1-10 for better readability
analysis_data <- sim %>% 
  filter(study <= 10)

meta_fixed <- metagen(TE = z,
                 seTE = se,
                 studlab = study,
                 data = analysis_data,
                 sm = "ZCOR",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis Fixed effect")

summary(meta_fixed)
#> Review:     Meta-Analysis Fixed effect
#> 
#>       COR           95%-CI %W(common)
#> 1  0.5094 [0.4703; 0.5466]       15.9
#> 2  0.5034 [0.4372; 0.5641]        5.9
#> 3  0.4631 [0.4144; 0.5092]       11.6
#> 4  0.4888 [0.4373; 0.5371]        9.9
#> 5  0.5697 [0.3316; 0.7395]        0.5
#> 6  0.5448 [0.5035; 0.5836]       13.1
#> 7  0.4519 [0.3637; 0.5321]        3.8
#> 8  0.4766 [0.4391; 0.5125]       18.8
#> 9  0.3901 [0.1366; 0.5956]        0.6
#> 10 0.4852 [0.4493; 0.5196]       20.1
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.4932 [0.4774; 0.5086] 51.43       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0005 [0.0000; 0.0052]; tau = 0.0213 [0.0000; 0.0718]
#>  I^2 = 22.4% [0.0%; 62.1%]; H = 1.14 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  11.60    9  0.2367
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Fisher's z transformation of correlations
```

### Forest plot

``` r
metafor::forest(meta_fixed,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "r", "SE"))
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

## Random Effects Model

### Simulate data

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         smd_true = 0,
         r_true = 0.5,
         es = 'ZCOR',
         random = TRUE,
         tau = 0.1)

head(sim)
#> # A tibble: 6 × 5
#>   study     z     r     n     se
#>   <int> <dbl> <dbl> <int>  <dbl>
#> 1     1 0.695 0.601  1432 0.0265
#> 2     2 0.425 0.401   407 0.0498
#> 3     3 0.359 0.344   232 0.0661
#> 4     4 0.603 0.539   728 0.0371
#> 5     5 0.456 0.427  1260 0.0282
#> 6     6 0.651 0.572   404 0.0499
```

### Run Meta-Analysis on simulated data

``` r

# choose only studies 1-10 for better readability
analysis_data <- sim %>% 
  filter(study <= 10)

meta_random <- metagen(TE = z,
                 seTE = se,
                 studlab = study,
                 data = analysis_data,
                 sm = "ZCOR",
                 fixed = FALSE,
                 random = TRUE,
                 method.tau = 'REML',
                 method.random.ci = "HK",
                 title = "Meta-Analysis Random Effects")

summary(meta_random)
#> Review:     Meta-Analysis Random Effects
#> 
#>       COR            95%-CI %W(random)
#> 1  0.6013 [ 0.5672; 0.6334]       11.7
#> 2  0.4010 [ 0.3162; 0.4796]       10.4
#> 3  0.3440 [ 0.2252; 0.4528]        9.3
#> 4  0.5390 [ 0.4853; 0.5886]       11.2
#> 5  0.4267 [ 0.3805; 0.4709]       11.6
#> 6  0.5722 [ 0.5027; 0.6343]       10.4
#> 7  0.3498 [ 0.2176; 0.4694]        8.8
#> 8  0.5575 [ 0.5231; 0.5901]       11.8
#> 9  0.3648 [-0.0354; 0.6642]        2.8
#> 10 0.5491 [ 0.5143; 0.5821]       11.8
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4913 [0.4185; 0.5578] 13.24 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0136 [0.0049; 0.0528]; tau = 0.1165 [0.0701; 0.2298]
#>  I^2 = 88.3% [80.6%; 93.0%]; H = 2.93 [2.27; 3.77]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  77.06    9 < 0.0001
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)
#> - Fisher's z transformation of correlations


metafor::forest(meta_random,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "r", "SE"))
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

# Subgroup-Analysis Standardized Mean Difference

### Simulate data

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         smd_true = 0.6,
         r_true = 0,
         es = 'SMD',
         random = TRUE,
         tau = 0.1,
         metaregression = TRUE,
         mod_varname = c('subgroup'),
         mod_labels = c('group1', 'group2'),
         mod_effect = 0.2)

head(sim %>% 
       select(study, hedges_g, subgroup, everything()))
#> # A tibble: 6 × 11
#>   study hedges_g subgroup     se  mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl> <chr>     <dbl>   <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.892 group1   0.0459 -0.115   0.767 0.977 1.00   1043  1043 0.00211
#> 2     2    0.873 group2   0.0420  0.0275  0.894 1.02  0.964  1244  1244 0.00176
#> 3     3    0.798 group2   0.0334 -0.0899  0.728 1.02  1.03   1939  1939 0.00111
#> 4     4    1.06  group2   0.0499 -0.124   0.905 0.989 0.959   914   914 0.00249
#> 5     5    0.356 group1   0.0331  0.220   0.576 1.03  0.975  1857  1857 0.00109
#> 6     6    0.549 group1   0.0390  0.193   0.747 0.975 1.04   1363  1363 0.00152
```

### Run Meta-Analysis on simulated data

``` r
# choose only studies 1-10 for better readability
analysis_data <- sim %>% 
  filter(study <= 10)

meta_random <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = analysis_data,
                 sm = "SMD",
                 fixed = FALSE,
                 random = TRUE,
                 method.tau = 'REML',
                 method.random.ci = "HK",
                 subgroup = subgroup,
                 title = "Meta-Analysis Random Effects")

summary(meta_random)
#> Review:     Meta-Analysis Random Effects
#> 
#>       SMD           95%-CI %W(random) subgroup
#> 1  0.8918 [0.8018; 0.9818]       10.4   group1
#> 2  0.8733 [0.7910; 0.9555]       10.4   group2
#> 3  0.7983 [0.7329; 0.8638]       10.6   group2
#> 4  1.0558 [0.9579; 1.1536]       10.3   group2
#> 5  0.3564 [0.2916; 0.4212]       10.6   group1
#> 6  0.5486 [0.4721; 0.6251]       10.5   group1
#> 7  0.4829 [0.4189; 0.5468]       10.6   group1
#> 8  0.7697 [0.4853; 1.0542]        7.4   group2
#> 9  0.7723 [0.5825; 0.9622]        9.0   group1
#> 10 0.6508 [0.5538; 0.7478]       10.3   group2
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7162 [0.5622; 0.8702] 10.52 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0446 [0.0192; 0.1462]; tau = 0.2113 [0.1387; 0.3823]
#>  I^2 = 96.5% [95.0%; 97.5%]; H = 5.32 [4.46; 6.36]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  255.14    9 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                     k    SMD           95%-CI  tau^2    tau     Q   I^2
#> subgroup = group1   5 0.6042 [0.3328; 0.8756] 0.0453 0.2129 98.20 95.9%
#> subgroup = group2   5 0.8350 [0.6441; 1.0260] 0.0212 0.1455 35.65 88.8%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                   Q d.f. p-value
#> Between groups 3.73    1  0.0534
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 9)


metafor::forest(meta_random,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "g", "SE"))
```

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />
