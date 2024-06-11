
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
         random = FALSE,
         metaregression = FALSE)

head(sim)
#> # A tibble: 6 × 14
#>   study hedges_g         z         r   se_g   se_z    mean1 mean2   sd1   sd2
#>   <int>    <dbl>     <dbl>     <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1     1    0.393  0.00315   0.00315  0.0663 0.0466 -0.0896  0.313 0.989 1.05 
#> 2     2    0.299 -0.00695  -0.00695  0.0358 0.0252 -0.0224  0.280 0.993 1.03 
#> 3     3    0.313 -0.00621  -0.00621  0.0414 0.0291  0.00757 0.328 1.04  1.00 
#> 4     4    0.350 -0.000387 -0.000387 0.0466 0.0327  0.0396  0.383 0.978 0.985
#> 5     5    0.272 -0.00378  -0.00378  0.0329 0.0232  0.0158  0.290 1.00  1.01 
#> 6     6    0.277 -0.0288   -0.0288   0.0346 0.0244 -0.0136  0.262 0.995 0.997
#> # ℹ 4 more variables: n1 <int>, n2 <int>, n <int>, variance_g <dbl>
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
#> 1  0.3935 [0.2635; 0.5234]        4.3
#> 2  0.2990 [0.2289; 0.3691]       14.9
#> 3  0.3133 [0.2321; 0.3945]       11.1
#> 4  0.3498 [0.2585; 0.4411]        8.8
#> 5  0.2725 [0.2081; 0.3369]       17.6
#> 6  0.2768 [0.2090; 0.3447]       15.9
#> 7  0.2576 [0.1306; 0.3846]        4.5
#> 8  0.2466 [0.1646; 0.3286]       10.9
#> 9  0.2742 [0.1451; 0.4034]        4.4
#> 10 0.3102 [0.2134; 0.4069]        7.8
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2932 [0.2662; 0.3202] 21.27 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0035]; tau = 0 [0.0000; 0.0594]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  6.39    9  0.7005
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
         random = TRUE,
         random_effects = c('SMD'),
         tau = 0.05)

head(sim)
#> # A tibble: 6 × 14
#>   study hedges_g        z        r   se_g   se_z   mean1 mean2   sd1   sd2    n1
#>   <int>    <dbl>    <dbl>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <dbl> <int>
#> 1     1    0.527  2.97e-2  2.96e-2 0.0322 0.0224  0.0480 0.576 1.01  1.00   1997
#> 2     2    0.507 -3.93e-3 -3.93e-3 0.0334 0.0232  0.0322 0.533 0.985 0.991  1856
#> 3     3    0.790 -1.96e-2 -1.96e-2 0.104  0.0712 -0.0364 0.775 1.02  1.03    200
#> 4     4    0.678  6.31e-4  6.31e-4 0.0365 0.0251  0.0517 0.730 1.01  0.987  1590
#> 5     5    0.747 -2.02e-2 -2.02e-2 0.0399 0.0273  0.0626 0.800 0.989 0.984  1346
#> 6     6    0.829  1.48e-3  1.48e-3 0.0502 0.0341 -0.126  0.698 1.02  0.966   863
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
#> 1  0.5268 [0.4637; 0.5899]       11.6
#> 2  0.5072 [0.4419; 0.5726]       11.6
#> 3  0.7902 [0.5867; 0.9937]        6.6
#> 4  0.6780 [0.6065; 0.7495]       11.4
#> 5  0.7470 [0.6689; 0.8252]       11.2
#> 6  0.8292 [0.7308; 0.9275]       10.4
#> 7  0.7175 [0.6326; 0.8023]       10.9
#> 8  0.7011 [0.5332; 0.8691]        7.8
#> 9  0.7666 [0.6371; 0.8961]        9.2
#> 10 0.5320 [0.4038; 0.6602]        9.3
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6722 [0.5873; 0.7571] 17.92 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0116 [0.0040; 0.0427]; tau = 0.1079 [0.0634; 0.2067]
#>  I^2 = 85.7% [75.5%; 91.6%]; H = 2.64 [2.02; 3.46]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  62.92    9 < 0.0001
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
#>   study hedges_g     z     r   se_g   se_z   mean1    mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>   <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1  0.0766  0.510 0.470 0.0869 0.0618 -0.0181  0.0597  1.06  0.968   265
#> 2     2 -0.0665  0.578 0.521 0.0422 0.0299 -0.0123 -0.0806  1.01  1.04   1122
#> 3     3 -0.0220  0.505 0.466 0.0490 0.0347 -0.0250 -0.0463  0.967 0.976   833
#> 4     4  0.0184  0.623 0.553 0.0425 0.0301 -0.0119  0.00690 0.996 1.04   1106
#> 5     5  0.00197 0.566 0.513 0.0428 0.0303 -0.0270 -0.0250  1.03  1.01   1091
#> 6     6  0.00184 0.534 0.489 0.0363 0.0257  0.0227  0.0246  1.01  1.01   1521
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
#> 1  0.4698 [0.3703; 0.5587]        2.4
#> 2  0.5212 [0.4772; 0.5625]       10.3
#> 3  0.4661 [0.4112; 0.5176]        7.6
#> 4  0.5529 [0.5106; 0.5926]       10.1
#> 5  0.5125 [0.4674; 0.5550]       10.0
#> 6  0.4885 [0.4493; 0.5259]       13.9
#> 7  0.4869 [0.4368; 0.5339]        8.7
#> 8  0.4771 [0.4382; 0.5142]       14.5
#> 9  0.4493 [0.3964; 0.4993]        8.5
#> 10 0.4946 [0.4557; 0.5316]       14.0
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.4949 [0.4806; 0.5089] 56.63       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0006 [0.0000; 0.0044]; tau = 0.0249 [0.0000; 0.0662]
#>  I^2 = 39.1% [0.0%; 70.9%]; H = 1.28 [1.00; 1.85]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  14.77    9  0.0974
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
#> 1     1   0.0785 0.372 0.356 0.0796 0.0565 -0.00243  0.0789  1.04  1.03    316
#> 2     2   0.0638 0.383 0.365 0.0466 0.0330 -0.00799  0.0546  0.978 0.982   921
#> 3     3   0.0142 0.618 0.549 0.0363 0.0257 -0.00935  0.00506 1.01  1.01   1515
#> 4     4   0.0308 0.348 0.335 0.0514 0.0364 -0.0482  -0.0178  0.993 0.981   756
#> 5     5   0.0269 0.450 0.422 0.0414 0.0293 -0.0108   0.0156  0.984 0.972  1169
#> 6     6   0.0207 0.537 0.491 0.0392 0.0278  0.0109   0.0316  1.00  1.01   1301
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
#> 1  0.3561 [0.2558; 0.4488]        8.1
#> 2  0.3650 [0.3077; 0.4197]       10.2
#> 3  0.5494 [0.5132; 0.5836]       10.8
#> 4  0.3347 [0.2698; 0.3965]        9.9
#> 5  0.4217 [0.3734; 0.4677]       10.5
#> 6  0.4907 [0.4483; 0.5309]       10.6
#> 7  0.4557 [0.4072; 0.5016]       10.4
#> 8  0.3890 [0.3168; 0.4568]        9.4
#> 9  0.4852 [0.4141; 0.5504]        9.1
#> 10 0.5053 [0.4672; 0.5414]       10.8
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4410 [0.3873; 0.4917] 16.51 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0070 [0.0027; 0.0260]; tau = 0.0839 [0.0521; 0.1613]
#>  I^2 = 87.2% [78.5%; 92.4%]; H = 2.80 [2.15; 3.63]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  70.34    9 < 0.0001
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
#> 1     1    0.141 group1     0.0223    2.23e-2 0.0327 0.0231  0.160   0.299 0.995
#> 2     2    0.298 group2    -0.0251   -2.51e-2 0.0614 0.0433  0.00985 0.312 1.04 
#> 3     3    0.617 group3     0.00912   9.12e-3 0.0354 0.0245 -0.0930  0.516 0.979
#> 4     4    0.464 group3    -0.00195  -1.95e-3 0.0512 0.0358 -0.0117  0.457 1.00 
#> 5     5    0.441 group3     0.000584  5.84e-4 0.0326 0.0228 -0.0345  0.410 0.987
#> 6     6    0.428 group3     0.0191    1.91e-2 0.0395 0.0277 -0.104   0.329 1.01 
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
#> 1  0.1408 [ 0.0767; 0.2050]        3.5    group1
#> 2  0.2981 [ 0.1778; 0.4183]        3.1    group2
#> 3  0.6173 [ 0.5480; 0.6867]        3.5    group3
#> 4  0.4642 [ 0.3639; 0.5644]        3.3    group3
#> 5  0.4411 [ 0.3772; 0.5050]        3.5    group3
#> 6  0.4279 [ 0.3505; 0.5054]        3.4    group3
#> 7  0.5215 [ 0.4327; 0.6103]        3.4    group2
#> 8  0.3131 [ 0.1659; 0.4603]        2.9    group2
#> 9  0.2369 [ 0.1571; 0.3168]        3.4    group2
#> 10 0.3063 [ 0.2398; 0.3729]        3.5    group2
#> 11 0.0395 [-0.1169; 0.1959]        2.8    group1
#> 12 0.2959 [ 0.2216; 0.3701]        3.5    group2
#> 13 0.3725 [ 0.2668; 0.4783]        3.2    group1
#> 14 0.4401 [ 0.3766; 0.5036]        3.5    group2
#> 15 0.3589 [ 0.2104; 0.5074]        2.9    group2
#> 16 0.4402 [ 0.3764; 0.5040]        3.5    group1
#> 17 0.6475 [ 0.5765; 0.7185]        3.5    group3
#> 18 0.3622 [ 0.2187; 0.5057]        2.9    group1
#> 19 0.5297 [ 0.3887; 0.6707]        2.9    group3
#> 20 0.3264 [ 0.2637; 0.3892]        3.5    group1
#> 21 0.4325 [ 0.3600; 0.5049]        3.5    group2
#> 22 0.5805 [ 0.5156; 0.6454]        3.5    group3
#> 23 0.6544 [ 0.5418; 0.7669]        3.2    group2
#> 24 0.4810 [ 0.3973; 0.5648]        3.4    group3
#> 25 0.4927 [ 0.3900; 0.5954]        3.3    group2
#> 26 0.3103 [ 0.2459; 0.3747]        3.5    group1
#> 27 0.3671 [ 0.2820; 0.4521]        3.4    group2
#> 28 0.6323 [ 0.5665; 0.6981]        3.5    group3
#> 29 0.2076 [ 0.1379; 0.2774]        3.5    group2
#> 30 0.5268 [ 0.4585; 0.5951]        3.5    group3
#> 
#> Number of studies: k = 30
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.4112 [0.3559; 0.4666] 15.20 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0195 [0.0116; 0.0377]; tau = 0.1397 [0.1079; 0.1942]
#>  I^2 = 92.3% [90.1%; 94.0%]; H = 3.60 [3.17; 4.08]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  375.77   29 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                      k    SMD           95%-CI  tau^2    tau     Q   I^2
#> subgroups = group1   7 0.2900 [0.1629; 0.4170] 0.0155 0.1244 56.14 89.3%
#> subgroups = group2  13 0.3776 [0.3019; 0.4533] 0.0133 0.1154 89.41 86.6%
#> subgroups = group3  10 0.5372 [0.4779; 0.5964] 0.0055 0.0740 44.05 79.6%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                    Q d.f.  p-value
#> Between groups 24.91    2 < 0.0001
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
