
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

### Simulate Data

Simulates data of multiple studies using predefined effect sizes and
between study heterogenity ($\tau$).

``` r
sim <- sim_meta(min_obs = 20,
         max_obs = 2000,
         n_studies = 1500,
         smd_true = 0.3,
         r_true = 0,
         random = FALSE,
         metaregression = FALSE)

head(sim)
#> # A tibble: 6 × 14
#>   study hedges_g       z       r   se_g   se_z    mean1 mean2   sd1   sd2    n1
#>   <int>    <dbl>   <dbl>   <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <dbl> <int>
#> 1     1    0.319  0.0395  0.0395 0.113  0.0803 -0.0132  0.297 1.02  0.925   158
#> 2     2    0.393  0.0339  0.0339 0.0482 0.0338  0.0301  0.409 0.978 0.953   876
#> 3     3    0.261 -0.0391 -0.0391 0.0668 0.0472  0.0120  0.294 1.05  1.11    452
#> 4     4    0.228  0.0102  0.0102 0.0332 0.0234  0.0260  0.256 1.01  1.00   1830
#> 5     5    0.286  0.0601  0.0600 0.0455 0.0320 -0.00445 0.282 1.01  0.990   978
#> 6     6    0.340  0.0320  0.0319 0.0532 0.0374 -0.00683 0.330 0.973 1.00    718
#> # ℹ 3 more variables: n2 <int>, n <int>, variance_g <dbl>
```

### Effect size and standard error

``` r
require(tidyverse)

ggplot(sim, aes(x = hedges_g, y = log(se_g), color = n1))+
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
#> Warning in check_dep_version(): ABI version mismatch: 
#> lme4 was built with Matrix ABI version 1
#> Current Matrix ABI version is 0
#> Please re-install lme4 from source or restore original 'Matrix' package

#select only studies 1-10 for better readability
sim <- sim %>% 
  filter(study <= 10)

meta_fixed <- metagen(TE = hedges_g,
                 seTE = se_g,
                 studlab = study,
                 data = sim,
                 sm = "SMD",
                 fixed = TRUE,
                 random = FALSE,
                 title = "Meta-Analysis Fixed effect")

summary(meta_fixed)
#> Review:     Meta-Analysis Fixed effect
#> 
#>       SMD           95%-CI %W(common)
#> 1  0.3191 [0.0972; 0.5410]        1.6
#> 2  0.3927 [0.2981; 0.4872]        8.8
#> 3  0.2614 [0.1304; 0.3923]        4.6
#> 4  0.2277 [0.1627; 0.2927]       18.6
#> 5  0.2858 [0.1968; 0.3749]        9.9
#> 6  0.3398 [0.2357; 0.4440]        7.2
#> 7  0.3264 [0.2524; 0.4004]       14.4
#> 8  0.2821 [0.1705; 0.3937]        6.3
#> 9  0.2986 [0.2328; 0.3644]       18.2
#> 10 0.3123 [0.2256; 0.3990]       10.5
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2984 [0.2704; 0.3265] 20.86 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0007 [0.0000; 0.0047]; tau = 0.0256 [0.0000; 0.0688]
#>  I^2 = 11.0% [0.0%; 51.7%]; H = 1.06 [1.00; 1.44]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  10.12    9  0.3412
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

### Simulate Data

``` r
sim <- sim_meta(min_obs = 200,
         max_obs = 2000,
         n_studies = 10,
         smd_true = 0.7,
         random = TRUE,
         random_effects = c('SMD'),
         tau = 0.05)

head(sim)
#> # A tibble: 6 × 14
#>   study hedges_g        z        r   se_g   se_z   mean1 mean2   sd1   sd2    n1
#>   <int>    <dbl>    <dbl>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <dbl> <int>
#> 1     1    0.990  0.0527   0.0526  0.0566 0.0379 -0.217  0.741 0.990 0.945   700
#> 2     2    0.728  0.0641   0.0640  0.0484 0.0332  0.0635 0.794 0.990 1.01    912
#> 3     3    0.649  0.00292  0.00292 0.0453 0.0312  0.0352 0.687 1.03  0.974  1027
#> 4     4    0.633  0.00670  0.00670 0.0380 0.0263  0.0470 0.675 0.981 1.00   1452
#> 5     5    0.761  0.0137   0.0137  0.0332 0.0227 -0.0335 0.713 0.969 0.993  1950
#> 6     6    0.699 -0.0387  -0.0387  0.0348 0.0239  0.0396 0.753 1.03  1.01   1748
#> # ℹ 3 more variables: n2 <int>, n <int>, variance_g <dbl>
```

### Run Meta-Analysis on simulated data

``` r
require(meta)
require(metafor)

meta_random <- metagen(TE = hedges_g,
                 seTE = se_g,
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
#> 1  0.9896 [0.8786; 1.1006]        9.6
#> 2  0.7284 [0.6337; 0.8232]       10.0
#> 3  0.6492 [0.5604; 0.7379]       10.1
#> 4  0.6328 [0.5583; 0.7073]       10.5
#> 5  0.7607 [0.6957; 0.8257]       10.7
#> 6  0.6992 [0.6309; 0.7675]       10.6
#> 7  0.7798 [0.7115; 0.8481]       10.6
#> 8  0.8852 [0.7019; 1.0686]        7.5
#> 9  0.4686 [0.3700; 0.5672]        9.9
#> 10 0.8321 [0.7609; 0.9033]       10.5
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7382 [0.6365; 0.8398] 16.43 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0172 [0.0069; 0.0668]; tau = 0.1312 [0.0832; 0.2585]
#>  I^2 = 87.5% [79.1%; 92.6%]; H = 2.83 [2.18; 3.66]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  72.07    9 < 0.0001
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
         random = FALSE)

head(sim)
#> # A tibble: 6 × 14
#>   study hedges_g     z     r   se_g   se_z    mean1   mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>    <dbl>   <dbl> <dbl> <dbl> <int>
#> 1     1 -0.0653  0.511 0.471 0.0665 0.0472  0.0186  -0.0449 0.945 0.997   452
#> 2     2  0.00314 0.595 0.533 0.0340 0.0240 -0.0145  -0.0113 1.02  1.01   1732
#> 3     3  0.0493  0.572 0.517 0.0571 0.0405  0.0518   0.103  1.02  1.06    613
#> 4     4 -0.0114  0.524 0.481 0.0357 0.0253 -0.00646 -0.0177 0.987 0.983  1570
#> 5     5 -0.0125  0.494 0.457 0.0461 0.0326 -0.00125 -0.0137 0.976 1.01    942
#> 6     6  0.0881  0.490 0.454 0.0876 0.0623 -0.0163   0.0659 0.945 0.916   261
#> # ℹ 3 more variables: n2 <int>, n <int>, variance_g <dbl>
```

### Run Meta-Analysis on simulated data

``` r
require(meta)

meta_fixed <- metagen(TE = z,
                 seTE = se_z,
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
#> 1  0.4709 [0.3959; 0.5397]        4.3
#> 2  0.5333 [0.4987; 0.5662]       16.7
#> 3  0.5171 [0.4566; 0.5728]        5.9
#> 4  0.4807 [0.4417; 0.5178]       15.1
#> 5  0.4572 [0.4052; 0.5063]        9.1
#> 6  0.4545 [0.3525; 0.5458]        2.5
#> 7  0.4709 [0.4301; 0.5098]       14.1
#> 8  0.4969 [0.4598; 0.5322]       16.1
#> 9  0.4923 [0.4437; 0.5380]        9.6
#> 10 0.5064 [0.4486; 0.5601]        6.6
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.4928 [0.4781; 0.5073] 54.92       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0003 [0.0000; 0.0026]; tau = 0.0182 [0.0000; 0.0513]
#>  I^2 = 16.0% [0.0%; 57.2%]; H = 1.09 [1.00; 1.53]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  10.71    9  0.2962
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
         random = TRUE,
         random_effects = c('ZCOR'),
         tau = 0.1)

head(sim)
#> # A tibble: 6 × 14
#>   study hedges_g     z     r   se_g   se_z    mean1    mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>    <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1  0.0390  0.662 0.580 0.0838 0.0595 -0.0507  -0.0102  1.04  1.04    285
#> 2     2  0.0355  0.529 0.484 0.0589 0.0418 -0.0542  -0.0197  0.983 0.961   576
#> 3     3 -0.0216  0.358 0.343 0.0362 0.0256 -0.00770 -0.0294  0.991 1.01   1529
#> 4     4  0.00595 0.425 0.401 0.0407 0.0288  0.0246   0.0306  1.02  1.01   1207
#> 5     5 -0.0275  0.478 0.445 0.0378 0.0268  0.0721   0.0440  1.01  1.03   1399
#> 6     6 -0.0135  0.313 0.303 0.0455 0.0322  0.00804 -0.00549 0.989 1.02    966
#> # ℹ 3 more variables: n2 <int>, n <int>, variance_g <dbl>
```

### Run Meta-Analysis on simulated data

``` r

meta_random <- metagen(TE = z,
                 seTE = se_z,
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
#> 1  0.5797 [0.4970; 0.6520]        8.7
#> 2  0.4845 [0.4194; 0.5446]        9.7
#> 3  0.3433 [0.2983; 0.3868]       10.4
#> 4  0.4012 [0.3528; 0.4475]       10.3
#> 5  0.4445 [0.4015; 0.4856]       10.3
#> 6  0.3030 [0.2446; 0.3592]       10.1
#> 7  0.5617 [0.5284; 0.5933]       10.4
#> 8  0.4002 [0.3145; 0.4794]        9.2
#> 9  0.2831 [0.2418; 0.3235]       10.5
#> 10 0.4057 [0.3623; 0.4474]       10.4
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4228 [0.3475; 0.4927] 11.53 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0139 [0.0059; 0.0504]; tau = 0.1178 [0.0770; 0.2245]
#>  I^2 = 94.2% [91.2%; 96.2%]; H = 4.14 [3.37; 5.10]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  154.57    9 < 0.0001
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

### Simulate Data

``` r
sim <- sim_meta(min_obs = 200,
         max_obs = 2000,
         n_studies = 30,
         smd_true = 0.2,
         r_true = 0,
         random = TRUE,
         tau = 0.1,
         random_effects = c('SMD'),
         metaregression = TRUE,
         smd_mod_effects = c(0.1,0.2,0.3),
         r_mod_effects = c(0,0,0),
         mod_labels = c('group1', 'group2', 'group3'))

head(sim %>% 
       select(study, hedges_g, subgroups, everything()))
#> # A tibble: 6 × 19
#>   study hedges_g subgroups         z        r   se_g   se_z    mean1 mean2   sd1
#>   <int>    <dbl> <chr>         <dbl>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl>
#> 1     1    0.469 group2     0.149     1.48e-1 0.0619 0.0433 -0.0337  0.437 1.01 
#> 2     2    0.243 group1    -0.0279   -2.79e-2 0.0728 0.0515  0.144   0.395 1.02 
#> 3     3    0.580 group2    -0.0322   -3.22e-2 0.0461 0.0320 -0.138   0.459 1.06 
#> 4     4    0.271 group3     0.000447  4.47e-4 0.0521 0.0367  0.103   0.369 0.971
#> 5     5    0.197 group1     0.000755  7.55e-4 0.0424 0.0299  0.147   0.344 0.998
#> 6     6    0.257 group2     0.00690   6.90e-3 0.0803 0.0568  0.00304 0.264 1.02 
#> # ℹ 9 more variables: sd2 <dbl>, n1 <int>, n2 <int>, n <int>,
#> #   smd_mod_effects <dbl>, r_mod_effects <dbl>, r_true <dbl>, smd_true <dbl>,
#> #   variance_g <dbl>
```

### Run Meta-Analysis on simulated data

``` r
meta_random <- metagen(TE = hedges_g,
                 seTE = se_g,
                 studlab = study,
                 data = sim,
                 sm = "SMD",
                 fixed = FALSE,
                 random = TRUE,
                 method.tau = 'REML',
                 method.random.ci = "HK",
                 subgroup = subgroups,
                 title = "Meta-Analysis Random Effects")

summary(meta_random)
#> Review:     Meta-Analysis Random Effects
#> 
#>       SMD            95%-CI %W(random) subgroups
#> 1  0.4690 [ 0.3477; 0.5902]        3.2    group2
#> 2  0.2428 [ 0.1001; 0.3855]        3.1    group1
#> 3  0.5796 [ 0.4892; 0.6700]        3.4    group2
#> 4  0.2715 [ 0.1694; 0.3735]        3.3    group3
#> 5  0.1969 [ 0.1138; 0.2800]        3.4    group1
#> 6  0.2568 [ 0.0995; 0.4141]        3.0    group2
#> 7  0.1956 [ 0.1246; 0.2667]        3.5    group1
#> 8  0.2821 [ 0.2043; 0.3599]        3.5    group2
#> 9  0.7727 [ 0.6641; 0.8814]        3.3    group3
#> 10 0.2300 [ 0.1523; 0.3077]        3.5    group1
#> 11 0.4367 [ 0.3250; 0.5483]        3.3    group2
#> 12 0.4745 [ 0.3597; 0.5892]        3.3    group2
#> 13 0.3397 [ 0.2569; 0.4224]        3.4    group3
#> 14 0.3934 [ 0.3089; 0.4779]        3.4    group1
#> 15 0.1802 [ 0.1152; 0.2452]        3.5    group2
#> 16 0.7282 [ 0.6536; 0.8029]        3.5    group3
#> 17 0.2314 [ 0.1513; 0.3115]        3.4    group2
#> 18 0.0884 [-0.0059; 0.1826]        3.4    group2
#> 19 0.2007 [ 0.0084; 0.3929]        2.7    group1
#> 20 0.4807 [ 0.3210; 0.6403]        3.0    group2
#> 21 0.2799 [ 0.2145; 0.3452]        3.5    group1
#> 22 0.3876 [ 0.3154; 0.4598]        3.5    group1
#> 23 0.7493 [ 0.6555; 0.8432]        3.4    group3
#> 24 0.5356 [ 0.4464; 0.6249]        3.4    group3
#> 25 0.4724 [ 0.4028; 0.5420]        3.5    group1
#> 26 0.3262 [ 0.2193; 0.4330]        3.3    group1
#> 27 0.4230 [ 0.3216; 0.5243]        3.3    group2
#> 28 0.4832 [ 0.3806; 0.5858]        3.3    group3
#> 29 0.3838 [ 0.3030; 0.4647]        3.4    group2
#> 30 0.1254 [ 0.0091; 0.2417]        3.3    group2
#> 
#> Number of studies: k = 30
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.3747 [0.3077; 0.4417] 11.44 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0297 [0.0178; 0.0553]; tau = 0.1722 [0.1334; 0.2352]
#>  I^2 = 93.3% [91.5%; 94.8%]; H = 3.87 [3.43; 4.37]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  434.17   29 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                      k    SMD           95%-CI  tau^2    tau      Q   I^2
#> subgroups = group2  13 0.3371 [0.2434; 0.4308] 0.0213 0.1459 116.72 89.7%
#> subgroups = group1  10 0.2985 [0.2273; 0.3698] 0.0081 0.0901  53.22 83.1%
#> subgroups = group3   7 0.5544 [0.3667; 0.7420] 0.0388 0.1969 110.24 94.6%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                   Q d.f. p-value
#> Between groups 9.53    2  0.0085
#> 
#> Details on meta-analytical method:
#> - Inverse variance method
#> - Restricted maximum-likelihood estimator for tau^2
#> - Q-Profile method for confidence interval of tau^2 and tau
#> - Hartung-Knapp adjustment for random effects model (df = 29)


metafor::forest(meta_random,
             prediction = TRUE, 
             print.tau2 = TRUE,
             leftlabs = c("Study", "g", "SE"))
```

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />

# Metaregression

## Simulate Data

``` r
# define values of moderator variable:
x <- 1:100/100

# define slope:
b <- -0.5

df <- sim_meta(min_obs = 100,
               max_obs = 1000,
               n_studies = 50,
               smd_true = 0,
               r_true = 0,
               random = FALSE,
               metaregression = TRUE,
               mod_name = 'moderator',
               smd_mod_effects = b*x,
               r_mod_effects = rep(0,100),
               mod_labels = x)

# show correlation between moderator and effect size
df %>% 
  mutate(g_upper = hedges_g + 1.96*se_g,
         g_lower = hedges_g - 1.96*se_g) %>% 
ggplot(aes(moderator,hedges_g))+
  geom_point()+
  geom_errorbar(aes(ymin = g_lower, ymax = g_upper))+
  geom_smooth(method = 'lm', se = FALSE, color = 'steelblue')
#> `geom_smooth()` using formula = 'y ~ x'
```

<img src="man/figures/README-unnamed-chunk-16-1.png" width="100%" />

``` r

mg <- metagen(TE = hedges_g,
              seTE = se_g,
              studlab = study,
              data = df,
              sm = "SMD",
              fixed = TRUE,
              random = FALSE,
              method.tau = 'REML',
              title = "Meta-Analysis fixed-effect",
              tau.common = FALSE)

m.gen.reg <- metareg(mg, ~moderator)

summary(m.gen.reg)
#> 
#> Mixed-Effects Model (k = 50; tau^2 estimator: REML)
#> 
#>    logLik   deviance        AIC        BIC       AICc   
#>   59.6692  -119.3385  -113.3385  -107.7249  -112.7930   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0.0003 (SE = 0.0007)
#> tau (square root of estimated tau^2 value):             0.0173
#> I^2 (residual heterogeneity / unaccounted variability): 7.79%
#> H^2 (unaccounted variability / sampling variability):   1.08
#> R^2 (amount of heterogeneity accounted for):            98.90%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 48) = 57.8494, p-val = 0.1561
#> 
#> Test of Moderators (coefficient 2):
#> QM(df = 1) = 299.2909, p-val < .0001
#> 
#> Model Results:
#> 
#>            estimate      se      zval    pval    ci.lb    ci.ub      
#> intrcpt      0.0144  0.0154    0.9345  0.3501  -0.0158   0.0446      
#> moderator   -0.5258  0.0304  -17.3000  <.0001  -0.5854  -0.4662  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

bubble(m.gen.reg, studlab = TRUE)
```

<img src="man/figures/README-unnamed-chunk-16-2.png" width="100%" />
