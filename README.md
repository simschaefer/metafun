
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
#>   study hedges_g     se   mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>    <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.338 0.0777 -0.00348  0.345 1.02  1.03    336   336 0.00604
#> 2     2    0.351 0.0462 -0.0264   0.332 1.02  1.02    951   951 0.00214
#> 3     3    0.339 0.0709 -0.0557   0.293 1.01  1.05    404   404 0.00502
#> 4     4    0.369 0.0552 -0.0361   0.325 0.953 1.00    668   668 0.00304
#> 5     5    0.258 0.0348  0.0288   0.291 1.01  1.03   1666  1666 0.00121
#> 6     6    0.269 0.0637  0.0259   0.292 0.998 0.976   497   497 0.00406
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
#>       SMD           95%-CI %W(common)
#> 1  0.3385 [0.1862; 0.4908]        4.6
#> 2  0.3508 [0.2602; 0.4414]       13.0
#> 3  0.3391 [0.2002; 0.4780]        5.5
#> 4  0.3690 [0.2609; 0.4772]        9.1
#> 5  0.2583 [0.1901; 0.3265]       22.9
#> 6  0.2689 [0.1440; 0.3938]        6.8
#> 7  0.3389 [0.2209; 0.4568]        7.7
#> 8  0.3103 [0.1321; 0.4884]        3.4
#> 9  0.2165 [0.0184; 0.4145]        2.7
#> 10 0.3306 [0.2643; 0.3970]       24.2
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3136 [0.2810; 0.3463] 18.82 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0033]; tau = 0.0085 [0.0000; 0.0571]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  6.26    9  0.7138
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
#>   study hedges_g     se   mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl>  <dbl>    <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.641 0.0400  0.0627   0.697 0.981 0.998  1311  1311 0.00160
#> 2     2    0.855 0.0409 -0.0306   0.823 0.977 1.02   1307  1307 0.00167
#> 3     3    0.567 0.0413 -0.0727   0.492 1.02  0.969  1219  1219 0.00171
#> 4     4    0.806 0.0530 -0.00846  0.794 0.994 0.996   771   771 0.00280
#> 5     5    0.676 0.0435  0.0177   0.692 1.02  0.971  1119  1119 0.00189
#> 6     6    0.607 0.0379  0.112    0.718 1.00  0.996  1453  1453 0.00144
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
#> 1  0.6407 [0.5622; 0.7191]       10.3
#> 2  0.8548 [0.7747; 0.9349]       10.2
#> 3  0.5672 [0.4862; 0.6481]       10.2
#> 4  0.8060 [0.7022; 0.9098]        9.4
#> 5  0.6758 [0.5906; 0.7610]       10.1
#> 6  0.6066 [0.5322; 0.6810]       10.4
#> 7  0.6020 [0.5371; 0.6668]       10.7
#> 8  0.5616 [0.4788; 0.6444]       10.2
#> 9  0.6947 [0.5505; 0.8389]        7.9
#> 10 0.8369 [0.7668; 0.9070]       10.6
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6834 [0.6032; 0.7637] 19.26 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0109 [0.0042; 0.0393]; tau = 0.1045 [0.0645; 0.1983]
#>  I^2 = 86.9% [77.9%; 92.3%]; H = 2.77 [2.13; 3.59]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  68.84    9 < 0.0001
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
#> 1     1 0.573 0.518  1634 0.0248
#> 2     2 0.523 0.480   523 0.0439
#> 3     3 0.484 0.449   942 0.0326
#> 4     4 0.571 0.516  1700 0.0243
#> 5     5 0.550 0.500   775 0.0360
#> 6     6 0.569 0.515  1850 0.0233
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
#> 1  0.5175 [0.4811; 0.5522]       14.2
#> 2  0.4801 [0.4113; 0.5434]        4.5
#> 3  0.4491 [0.3966; 0.4987]        8.2
#> 4  0.5158 [0.4800; 0.5499]       14.8
#> 5  0.5004 [0.4457; 0.5514]        6.7
#> 6  0.5149 [0.4806; 0.5477]       16.1
#> 7  0.5087 [0.4654; 0.5495]       10.4
#> 8  0.4911 [0.4404; 0.5387]        8.0
#> 9  0.4733 [0.4242; 0.5196]        8.9
#> 10 0.5075 [0.4590; 0.5530]        8.3
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.5009 [0.4871; 0.5145] 59.00       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0019]; tau = 0 [0.0000; 0.0440]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  8.46    9  0.4885
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
#> 1     1 0.686 0.595   381 0.0514
#> 2     2 0.599 0.536  1601 0.0250
#> 3     3 0.592 0.532   927 0.0329
#> 4     4 0.502 0.464   313 0.0568
#> 5     5 0.366 0.350  1538 0.0255
#> 6     6 0.569 0.515   866 0.0340
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
#> 1  0.5954 [0.5264; 0.6566]        8.9
#> 2  0.5364 [0.5006; 0.5704]       10.6
#> 3  0.5316 [0.4838; 0.5762]       10.2
#> 4  0.4637 [0.3719; 0.5465]        8.4
#> 5  0.3501 [0.3054; 0.3932]       10.6
#> 6  0.5146 [0.4639; 0.5620]       10.1
#> 7  0.3403 [0.2896; 0.3891]       10.4
#> 8  0.4338 [0.3839; 0.4811]       10.3
#> 9  0.4593 [0.4112; 0.5050]       10.3
#> 10 0.4538 [0.4006; 0.5040]       10.1
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4692 [0.4095; 0.5249] 15.55 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0095 [0.0038; 0.0345]; tau = 0.0972 [0.0618; 0.1858]
#>  I^2 = 90.6% [84.8%; 94.1%]; H = 3.25 [2.56; 4.13]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  95.30    9 < 0.0001
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
#>   study hedges_g subgroup     se   mean_x mean_y  sd_x  sd_y   n_x   n_y      vi
#>   <int>    <dbl> <chr>     <dbl>    <dbl>  <dbl> <dbl> <dbl> <int> <int>   <dbl>
#> 1     1    0.901 group2   0.0365 -0.162    0.753 1.01  1.02   1658  1658 0.00133
#> 2     2    0.929 group2   0.0339 -0.00998  0.910 0.986 0.995  1927  1927 0.00115
#> 3     3    0.867 group1   0.0463 -0.172    0.704 1.01  1.01   1022  1022 0.00214
#> 4     4    0.709 group1   0.0445  0.0863   0.770 0.962 0.966  1072  1072 0.00198
#> 5     5    0.632 group1   0.0379  0.0451   0.677 1.00  0.996  1460  1460 0.00144
#> 6     6    0.631 group1   0.0405 -0.0923   0.525 0.982 0.976  1278  1278 0.00164
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
#> 1  0.9007 [0.8293; 0.9722]        6.9   group2
#> 2  0.9289 [0.8624; 0.9953]        6.9   group2
#> 3  0.8668 [0.7761; 0.9575]        6.7   group1
#> 4  0.7088 [0.6215; 0.7960]        6.7   group1
#> 5  0.6323 [0.5580; 0.7067]        6.9   group1
#> 6  0.6308 [0.5513; 0.7102]        6.8   group1
#> 7  0.5823 [0.4839; 0.6807]        6.6   group1
#> 8  0.5846 [0.5180; 0.6511]        6.9   group1
#> 9  0.6132 [0.5314; 0.6951]        6.8   group1
#> 10 0.4513 [0.3286; 0.5741]        6.2   group1
#> 11 0.6526 [0.5819; 0.7233]        6.9   group1
#> 12 0.6624 [0.5891; 0.7358]        6.9   group1
#> 13 0.5574 [0.4588; 0.6559]        6.6   group1
#> 14 1.0014 [0.8655; 1.1373]        6.0   group2
#> 15 0.4792 [0.3591; 0.5992]        6.3   group1
#> 
#> Number of studies: k = 15
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6841 [0.5934; 0.7747] 16.19 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0240 [0.0119; 0.0656]; tau = 0.1548 [0.1092; 0.2562]
#>  I^2 = 92.0% [88.4%; 94.4%]; H = 3.53 [2.94; 4.24]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  174.70   14 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                     k    SMD           95%-CI   tau^2    tau     Q   I^2
#> subgroup = group2   3 0.9256 [0.8336; 1.0175] <0.0001 0.0020  1.67  0.0%
#> subgroup = group1  12 0.6228 [0.5567; 0.6890]  0.0082 0.0905 49.60 77.8%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                    Q d.f.  p-value
#> Between groups 67.38    1 < 0.0001
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
