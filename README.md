
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
#>   study hedges_g     se  mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.308 0.0677 -0.0499  0.263 0.980 1.05    441   441 0.00459
#> 2     2    0.202 0.191  -0.0418  0.151 1.05  0.831    55    55 0.0365 
#> 3     3    0.355 0.0559 -0.0928  0.260 0.981 1.01    649   649 0.00313
#> 4     4    0.212 0.0468  0.0256  0.240 1.01  1.01    919   919 0.00219
#> 5     5    0.264 0.0669  0.0213  0.287 1.01  1.01    451   451 0.00447
#> 6     6    0.348 0.0397  0.0136  0.363 0.999 1.01   1291  1291 0.00157
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

#select only studies 1-10 for better readability
sim <- sim %>% 
  filter(study <= 10)

meta_fixed <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = sim,
                 sm = "SMD",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis Fixed effect")

summary(meta_fixed)
#> Review:     Meta-Analysis Fixed effect
#> 
#>       SMD            95%-CI %W(common)
#> 1  0.3078 [ 0.1751; 0.4406]        5.0
#> 2  0.2016 [-0.1731; 0.5763]        0.6
#> 3  0.3547 [ 0.2450; 0.4643]        7.3
#> 4  0.2115 [ 0.1198; 0.3032]       10.4
#> 5  0.2642 [ 0.1331; 0.3952]        5.1
#> 6  0.3484 [ 0.2707; 0.4261]       14.5
#> 7  0.3153 [ 0.2495; 0.3810]       20.3
#> 8  0.2207 [ 0.1285; 0.3129]       10.3
#> 9  0.3140 [ 0.2262; 0.4018]       11.4
#> 10 0.3515 [ 0.2751; 0.4279]       15.0
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3040 [0.2743; 0.3336] 20.11 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0009 [0.0000; 0.0073]; tau = 0.0302 [0.0000; 0.0857]
#>  I^2 = 21.1% [0.0%; 61.3%]; H = 1.13 [1.00; 1.61]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  11.41    9  0.2485
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
sim <- sim_meta(min_obs = 200,
         max_obs = 2000,
         n_studies = 10,
         smd_true = 0.7,
         es = 'SMD',
         random = TRUE,
         tau = 0.05)

head(sim)
#> # A tibble: 6 × 10
#>   study hedges_g     se  mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.735 0.0469 -0.0140  0.720 0.993 1.00    972   972 0.00220
#> 2     2    0.707 0.0361  0.0604  0.767 0.993 1.01   1634  1634 0.00130
#> 3     3    0.735 0.0708  0.0114  0.765 1.04  1.01    426   426 0.00501
#> 4     4    0.741 0.0553  0.0348  0.783 0.994 1.02    699   699 0.00306
#> 5     5    0.782 0.0449 -0.0791  0.710 1.03  0.989  1070  1070 0.00201
#> 6     6    0.707 0.0489  0.0600  0.749 0.993 0.957   890   890 0.00239
```

### Run Meta-Analysis on simulated data

``` r
require(meta)
require(metafor)

meta_random <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = sim,
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
#> 1  0.7349 [0.6430; 0.8267]        8.5
#> 2  0.7068 [0.6361; 0.7775]       14.4
#> 3  0.7350 [0.5963; 0.8738]        3.7
#> 4  0.7408 [0.6324; 0.8492]        6.1
#> 5  0.7817 [0.6938; 0.8696]        9.3
#> 6  0.7066 [0.6108; 0.8023]        7.8
#> 7  0.7490 [0.6786; 0.8194]       14.5
#> 8  0.8624 [0.7125; 1.0122]        3.2
#> 9  0.7440 [0.6755; 0.8124]       15.3
#> 10 0.7063 [0.6413; 0.7713]       17.0
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7360 [0.7112; 0.7608] 67.13 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0033]; tau = 0 [0.0000; 0.0570]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  5.78    9  0.7618
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
sim <- sim_meta(min_obs = 200,
         max_obs = 2000,
         n_studies = 10,
         smd_true = 0,
         r_true = 0.5,
         es = 'ZCOR',
         random = FALSE)

head(sim)
#> # A tibble: 6 × 5
#>   study     z     r     n     se
#>   <int> <dbl> <dbl> <int>  <dbl>
#> 1     1 0.498 0.461  1331 0.0274
#> 2     2 0.560 0.508   960 0.0323
#> 3     3 0.563 0.511  1874 0.0231
#> 4     4 0.569 0.515  1448 0.0263
#> 5     5 0.522 0.480   828 0.0348
#> 6     6 0.596 0.534  1575 0.0252
```

### Run Meta-Analysis on simulated data

``` r
require(meta)

meta_fixed <- metagen(TE = z,
                 seTE = se,
                 studlab = study,
                 data = sim,
                 sm = "ZCOR",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis Fixed effect")

summary(meta_fixed)
#> Review:     Meta-Analysis Fixed effect
#> 
#>       COR           95%-CI %W(common)
#> 1  0.4606 [0.4171; 0.5019]       10.9
#> 2  0.5077 [0.4591; 0.5532]        7.8
#> 3  0.5105 [0.4763; 0.5432]       15.3
#> 4  0.5148 [0.4759; 0.5517]       11.8
#> 5  0.4796 [0.4253; 0.5304]        6.7
#> 6  0.5343 [0.4981; 0.5687]       12.9
#> 7  0.5012 [0.4339; 0.5629]        4.2
#> 8  0.4783 [0.4431; 0.5119]       15.8
#> 9  0.5097 [0.4593; 0.5569]        7.2
#> 10 0.4957 [0.4448; 0.5433]        7.4
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.5000 [0.4866; 0.5132] 60.75       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0002 [0.0000; 0.0020]; tau = 0.0156 [0.0000; 0.0446]
#>  I^2 = 13.1% [0.0%; 54.3%]; H = 1.07 [1.00; 1.48]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  10.36    9  0.3223
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
sim <- sim_meta(min_obs = 200,
         max_obs = 2000,
         n_studies = 10,
         smd_true = 0,
         r_true = 0.5,
         es = 'ZCOR',
         random = TRUE,
         tau = 0.1)

head(sim)
#> # A tibble: 6 × 5
#>   study     z     r     n     se
#>   <int> <dbl> <dbl> <int>  <dbl>
#> 1     1 0.288 0.280  1358 0.0272
#> 2     2 0.459 0.429  1118 0.0299
#> 3     3 0.819 0.674   925 0.0329
#> 4     4 0.372 0.356   708 0.0377
#> 5     5 0.406 0.385  1592 0.0251
#> 6     6 0.847 0.689   397 0.0504
```

### Run Meta-Analysis on simulated data

``` r

meta_random <- metagen(TE = z,
                 seTE = se,
                 studlab = study,
                 data = sim,
                 sm = "ZCOR",
                 fixed = FALSE,
                 random = TRUE,
                 method.tau = 'REML',
                 method.random.ci = "HK",
                 title = "Meta-Analysis Random Effects")

summary(meta_random)
#> Review:     Meta-Analysis Random Effects
#> 
#>       COR           95%-CI %W(random)
#> 1  0.2805 [0.2307; 0.3288]       10.1
#> 2  0.4290 [0.3799; 0.4757]       10.1
#> 3  0.6745 [0.6378; 0.7082]       10.0
#> 4  0.3562 [0.2901; 0.4188]        9.9
#> 5  0.3852 [0.3426; 0.4263]       10.2
#> 6  0.6893 [0.6339; 0.7377]        9.6
#> 7  0.3487 [0.2720; 0.4209]        9.8
#> 8  0.3780 [0.3162; 0.4366]       10.0
#> 9  0.4374 [0.3795; 0.4920]       10.0
#> 10 0.4728 [0.4370; 0.5072]       10.2
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI    t  p-value
#> Random effects model (HK) 0.4561 [0.3431; 0.5560] 8.26 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0339 [0.0154; 0.1181]; tau = 0.1840 [0.1241; 0.3436]
#>  I^2 = 96.2% [94.6%; 97.4%]; H = 5.16 [4.31; 6.19]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  239.90    9 < 0.0001
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
sim <- sim_meta(min_obs = 200,
         max_obs = 2000,
         n_studies = 15,
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
#> 1     1    0.934 group2   0.0366 -0.0305  0.901 1.00  0.990  1655  1655 0.00134
#> 2     2    0.853 group2   0.0379 -0.0936  0.768 1.03  0.995  1515  1515 0.00144
#> 3     3    0.735 group1   0.0708 -0.140   0.587 1.01  0.965   426   426 0.00501
#> 4     4    0.750 group2   0.0360  0.135   0.874 0.985 0.982  1651  1651 0.00130
#> 5     5    1.02  group2   0.0608  0.0639  1.08  1.02  0.980   610   610 0.00370
#> 6     6    0.699 group1   0.0597 -0.0730  0.639 1.00  1.03    595   595 0.00357
```

### Run Meta-Analysis on simulated data

``` r
meta_random <- metagen(TE = hedges_g,
                 seTE = se,
                 studlab = study,
                 data = sim,
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
#> 1  0.9341 [0.8624; 1.0059]        7.0   group2
#> 2  0.8528 [0.7784; 0.9271]        6.9   group2
#> 3  0.7347 [0.5960; 0.8735]        6.2   group1
#> 4  0.7504 [0.6798; 0.8210]        7.0   group2
#> 5  1.0150 [0.8958; 1.1343]        6.5   group2
#> 6  0.6991 [0.5820; 0.8161]        6.5   group1
#> 7  0.4572 [0.3245; 0.5899]        6.3   group1
#> 8  0.6689 [0.6013; 0.7364]        7.0   group2
#> 9  0.3439 [0.2659; 0.4218]        6.9   group1
#> 10 0.5853 [0.4786; 0.6921]        6.6   group1
#> 11 0.6399 [0.5372; 0.7426]        6.7   group1
#> 12 0.6091 [0.5251; 0.6932]        6.9   group2
#> 13 0.5680 [0.4316; 0.7043]        6.2   group1
#> 14 0.7015 [0.5770; 0.8260]        6.4   group2
#> 15 0.8712 [0.7959; 0.9465]        6.9   group1
#> 
#> Number of studies: k = 15
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6967 [0.5984; 0.7951] 15.19 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0291 [0.0143; 0.0755]; tau = 0.1705 [0.1196; 0.2747]
#>  I^2 = 93.4% [90.7%; 95.3%]; H = 3.90 [3.28; 4.63]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  212.62   14 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                     k    SMD           95%-CI  tau^2    tau      Q   I^2
#> subgroup = group2   7 0.7888 [0.6528; 0.9248] 0.0192 0.1387  64.80 90.7%
#> subgroup = group1   8 0.6126 [0.4727; 0.7526] 0.0258 0.1607 102.18 93.1%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                   Q d.f. p-value
#> Between groups 4.71    1  0.0300
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 14)


metafor::forest(meta_random,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "g", "SE"))
```

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />
