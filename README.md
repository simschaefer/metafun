
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
#>   study hedges_g         z         r   se_g   se_z    mean1 mean2   sd1   sd2
#>   <int>    <dbl>     <dbl>     <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1     1    0.297 -0.0434   -0.0434   0.0518 0.0365 -0.00240 0.296 1.01  1.00 
#> 2     2    0.289  0.00670   0.00670  0.0435 0.0306  0.0251  0.298 0.937 0.950
#> 3     3    0.269  0.0904    0.0902   0.0695 0.0491 -0.00780 0.268 1.05  1.01 
#> 4     4    0.293 -0.00682  -0.00682  0.104  0.0737 -0.0597  0.226 0.898 1.04 
#> 5     5    0.393  0.0329    0.0328   0.0440 0.0309 -0.0690  0.327 1.00  1.01 
#> 6     6    0.158 -0.000579 -0.000579 0.132  0.0941  0.0509  0.204 0.875 1.05 
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
#>       SMD            95%-CI %W(common)
#> 1  0.2969 [ 0.1953; 0.3984]        9.3
#> 2  0.2892 [ 0.2041; 0.3744]       13.2
#> 3  0.2687 [ 0.1325; 0.4048]        5.2
#> 4  0.2933 [ 0.0895; 0.4971]        2.3
#> 5  0.3932 [ 0.3069; 0.4796]       12.9
#> 6  0.1583 [-0.0994; 0.4161]        1.4
#> 7  0.2847 [ 0.2109; 0.3584]       17.7
#> 8  0.3104 [ 0.1919; 0.4290]        6.8
#> 9  0.2819 [ 0.1771; 0.3866]        8.8
#> 10 0.3110 [ 0.2455; 0.3766]       22.4
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3054 [0.2744; 0.3364] 19.31 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0039]; tau = 0 [0.0000; 0.0626]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  6.22    9  0.7179
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
#>   study hedges_g       z       r   se_g   se_z    mean1 mean2   sd1   sd2    n1
#>   <int>    <dbl>   <dbl>   <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <dbl> <int>
#> 1     1    0.726  0.0280  0.0280 0.0442 0.0303  0.00755 0.744 0.990  1.04  1091
#> 2     2    0.684  0.0379  0.0379 0.0377 0.0259  0.00763 0.689 0.974  1.02  1492
#> 3     3    0.731  0.0234  0.0234 0.0534 0.0367  0.0237  0.770 1.03   1.01   747
#> 4     4    0.763 -0.0162 -0.0162 0.0339 0.0232 -0.0192  0.750 1.01   1.01  1862
#> 5     5    0.690  0.0229  0.0229 0.0699 0.0482 -0.0603  0.653 1.03   1.04   434
#> 6     6    0.692  0.0121  0.0121 0.0367 0.0252  0.0421  0.731 0.977  1.01  1578
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
#> 1  0.7256 [0.6390; 0.8123]        9.2
#> 2  0.6839 [0.6101; 0.7578]       11.2
#> 3  0.7314 [0.6267; 0.8362]        7.1
#> 4  0.7633 [0.6968; 0.8299]       12.5
#> 5  0.6903 [0.5533; 0.8272]        4.7
#> 6  0.6924 [0.6205; 0.7642]       11.5
#> 7  0.6397 [0.5697; 0.7096]       11.9
#> 8  0.7113 [0.6218; 0.8007]        8.8
#> 9  0.8085 [0.7330; 0.8841]       10.9
#> 10 0.7421 [0.6743; 0.8100]       12.3
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7202 [0.6848; 0.7556] 45.99 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0011 [0.0000; 0.0059]; tau = 0.0329 [0.0000; 0.0766]
#>  I^2 = 36.4% [0.0%; 69.7%]; H = 1.25 [1.00; 1.82]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  14.14    9  0.1173
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
#>   study hedges_g     z     r   se_g   se_z     mean1    mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>     <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1 -0.0280  0.525 0.482 0.0435 0.0308  0.0188   -0.00917 1.00  0.998  1057
#> 2     2 -0.0141  0.586 0.527 0.0544 0.0386  0.0553    0.0408  1.03  1.01    675
#> 3     3  0.0128  0.561 0.509 0.0316 0.0224 -0.00200   0.0108  0.999 0.993  1997
#> 4     4  0.00708 0.565 0.512 0.0416 0.0295 -0.0293   -0.0222  0.987 0.999  1153
#> 5     5  0.0659  0.607 0.542 0.0681 0.0483 -0.000619  0.0642  1.03  0.937   432
#> 6     6  0.00497 0.519 0.477 0.0372 0.0263 -0.0124   -0.00749 0.980 1.01   1445
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
#> 1  0.4818 [0.4341; 0.5268]       10.4
#> 2  0.5267 [0.4700; 0.5792]        6.6
#> 3  0.5089 [0.4757; 0.5407]       19.6
#> 4  0.5119 [0.4680; 0.5533]       11.3
#> 5  0.5421 [0.4719; 0.6055]        4.2
#> 6  0.4771 [0.4363; 0.5160]       14.2
#> 7  0.4593 [0.4048; 0.5106]        8.4
#> 8  0.5192 [0.4446; 0.5866]        4.0
#> 9  0.4389 [0.3778; 0.4962]        7.0
#> 10 0.4551 [0.4132; 0.4951]       14.2
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.4887 [0.4738; 0.5034] 53.85       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0006 [0.0000; 0.0054]; tau = 0.0236 [0.0000; 0.0737]
#>  I^2 = 37.9% [0.0%; 70.4%]; H = 1.27 [1.00; 1.84]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  14.48    9  0.1062
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
#>   study hedges_g     z     r   se_g   se_z   mean1    mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>   <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1  0.0130  0.518 0.476 0.0395 0.0280 -0.0233 -0.0101  1.00  1.01   1279
#> 2     2  0.00709 0.502 0.464 0.0318 0.0225 -0.0312 -0.0241  1.00  0.997  1983
#> 3     3 -0.0147  0.439 0.413 0.0321 0.0227 -0.0350 -0.0497  1.01  0.993  1936
#> 4     4 -0.0271  0.243 0.239 0.0393 0.0278  0.0225 -0.00460 1.03  0.968  1296
#> 5     5 -0.0150  0.423 0.399 0.0366 0.0259  0.0209  0.00573 0.990 1.04   1496
#> 6     6 -0.0481  0.504 0.466 0.0821 0.0583  0.0343 -0.0115  0.975 0.927   297
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
#> 1  0.4758 [0.4323; 0.5171]       10.2
#> 2  0.4639 [0.4286; 0.4978]       10.4
#> 3  0.4131 [0.3755; 0.4494]       10.4
#> 4  0.2387 [0.1867; 0.2894]       10.2
#> 5  0.3994 [0.3560; 0.4412]       10.3
#> 6  0.4656 [0.3715; 0.5502]        8.2
#> 7  0.3423 [0.3009; 0.3824]       10.4
#> 8  0.3348 [0.2925; 0.3759]       10.4
#> 9  0.4964 [0.4333; 0.5546]        9.4
#> 10 0.5186 [0.4804; 0.5549]       10.3
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4164 [0.3529; 0.4760] 13.45 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0100 [0.0042; 0.0350]; tau = 0.1000 [0.0651; 0.1872]
#>  I^2 = 92.9% [89.0%; 95.4%]; H = 3.75 [3.01; 4.68]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  126.77    9 < 0.0001
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
#>   study hedges_g subgroups        z        r   se_g   se_z   mean1 mean2   sd1
#>   <int>    <dbl> <chr>        <dbl>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>
#> 1     1    0.318 group2     0.00636  0.00636 0.0318 0.0224  0.0166 0.336 0.993
#> 2     2    0.274 group1     0.0224   0.0224  0.0428 0.0302  0.0451 0.321 0.978
#> 3     3    0.500 group2    -0.0397  -0.0397  0.0453 0.0316  0.0193 0.520 1.00 
#> 4     4    0.295 group1     0.0346   0.0346  0.0517 0.0364  0.0101 0.311 1.03 
#> 5     5    0.326 group1     0.0108   0.0108  0.0429 0.0302 -0.0103 0.328 1.02 
#> 6     6    0.354 group2     0.0336   0.0336  0.0382 0.0268  0.0152 0.364 0.982
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
#>       SMD           95%-CI %W(random) subgroups
#> 1  0.3176 [0.2551; 0.3800]        3.6    group2
#> 2  0.2744 [0.1905; 0.3583]        3.5    group1
#> 3  0.4996 [0.4108; 0.5884]        3.4    group2
#> 4  0.2954 [0.1941; 0.3968]        3.3    group1
#> 5  0.3262 [0.2421; 0.4104]        3.5    group1
#> 6  0.3543 [0.2794; 0.4292]        3.5    group2
#> 7  0.3941 [0.2149; 0.5732]        2.7    group1
#> 8  0.1821 [0.1085; 0.2557]        3.5    group1
#> 9  0.4096 [0.3331; 0.4862]        3.5    group2
#> 10 0.3442 [0.2046; 0.4838]        3.0    group3
#> 11 0.3634 [0.2327; 0.4941]        3.1    group3
#> 12 0.6054 [0.4519; 0.7589]        2.9    group2
#> 13 0.5986 [0.5230; 0.6741]        3.5    group3
#> 14 0.4471 [0.3286; 0.5656]        3.2    group2
#> 15 0.2016 [0.1270; 0.2761]        3.5    group1
#> 16 0.1886 [0.0572; 0.3200]        3.1    group1
#> 17 0.6045 [0.5262; 0.6828]        3.5    group3
#> 18 0.2795 [0.2131; 0.3458]        3.6    group1
#> 19 0.3030 [0.1429; 0.4632]        2.8    group1
#> 20 0.2487 [0.1650; 0.3324]        3.5    group2
#> 21 0.2863 [0.2103; 0.3623]        3.5    group1
#> 22 0.3954 [0.2191; 0.5717]        2.7    group1
#> 23 0.2742 [0.2072; 0.3412]        3.6    group1
#> 24 0.4532 [0.3852; 0.5212]        3.6    group2
#> 25 0.6518 [0.5633; 0.7403]        3.4    group3
#> 26 0.4764 [0.3524; 0.6003]        3.2    group3
#> 27 0.5195 [0.4426; 0.5964]        3.5    group2
#> 28 0.4718 [0.3952; 0.5483]        3.5    group3
#> 29 0.5885 [0.4765; 0.7005]        3.3    group3
#> 30 0.7304 [0.6295; 0.8313]        3.3    group3
#> 
#> Number of studies: k = 30
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.4021 [0.3469; 0.4572] 14.91 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0194 [0.0112; 0.0364]; tau = 0.1394 [0.1059; 0.1908]
#>  I^2 = 90.6% [87.7%; 92.8%]; H = 3.26 [2.85; 3.72]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  307.58   29 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                      k    SMD           95%-CI  tau^2    tau     Q   I^2
#> subgroups = group2   9 0.4210 [0.3395; 0.5026] 0.0087 0.0934 44.55 82.0%
#> subgroups = group1  12 0.2679 [0.2312; 0.3046] 0.0009 0.0301 16.25 32.3%
#> subgroups = group3   9 0.5429 [0.4447; 0.6412] 0.0129 0.1135 42.29 81.1%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                    Q d.f.  p-value
#> Between groups 45.24    2 < 0.0001
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
#>   62.1422  -124.2843  -118.2843  -112.6707  -117.7389   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0 (SE = 0.0008)
#> tau (square root of estimated tau^2 value):             0
#> I^2 (residual heterogeneity / unaccounted variability): 0.00%
#> H^2 (unaccounted variability / sampling variability):   1.00
#> R^2 (amount of heterogeneity accounted for):            100.00%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 48) = 44.2197, p-val = 0.6285
#> 
#> Test of Moderators (coefficient 2):
#> QM(df = 1) = 287.8707, p-val < .0001
#> 
#> Model Results:
#> 
#>            estimate      se      zval    pval    ci.lb    ci.ub      
#> intrcpt      0.0200  0.0209    0.9582  0.3379  -0.0210   0.0611      
#> moderator   -0.5208  0.0307  -16.9668  <.0001  -0.5809  -0.4606  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

bubble(m.gen.reg, studlab = TRUE)
```

<img src="man/figures/README-unnamed-chunk-16-2.png" width="100%" />

# Multiple Metaregression

Simulate data

``` r
data <- sim_metareg(random = TRUE,
                    tau = 0.05,
                    formula = y ~ 0.1*group + 0.05*quality + 0.2*control,
                    mod_types = c('cat', 'cont', 'cat'))

head(data)
#> 
#>    hedges_g   n         se intercept group     quality control         m     yi 
#> 1 0.7612619 286 0.06364739 0.5831615     0 -0.43799202       1 0.8293722 0.8294 
#> 2 0.6267840 369 0.04905481 0.5185627     1  0.16442459       0 0.7155982 0.7156 
#> 3 0.4507680 173 0.07324254 0.4499599     0  0.01616168       0 0.3690821 0.3691 
#> 4 0.8539997 379 0.05170797 0.4937360     1  1.20527389       1 0.8358752 0.8359 
#> 5 0.6629329 450 0.04806300 0.4947385     1  1.36388659       0 0.6050749 0.6051 
#> 6 0.5062324 326 0.05625657 0.4515075     1 -0.90550086       0 0.4002363 0.4002 
#>       vi 
#> 1 0.0041 
#> 2 0.0024 
#> 3 0.0054 
#> 4 0.0027 
#> 5 0.0023 
#> 6 0.0032
```

Conduct Meta-Analysis

``` r
meta <- rma(yi = hedges_g,
            sei = se,
            data = data,
            mods = ~ group + quality +control)

summary(meta)
#> 
#> Mixed-Effects Model (k = 100; tau^2 estimator: REML)
#> 
#>    logLik   deviance        AIC        BIC       AICc   
#>  150.0729  -300.1458  -290.1458  -277.3241  -289.4791   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0 (SE = 0.0005)
#> tau (square root of estimated tau^2 value):             0
#> I^2 (residual heterogeneity / unaccounted variability): 0.00%
#> H^2 (unaccounted variability / sampling variability):   1.00
#> R^2 (amount of heterogeneity accounted for):            100.00%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 96) = 60.4597, p-val = 0.9983
#> 
#> Test of Moderators (coefficients 2:4):
#> QM(df = 3) = 477.4327, p-val < .0001
#> 
#> Model Results:
#> 
#>          estimate      se     zval    pval   ci.lb   ci.ub      
#> intrcpt    0.4930  0.0098  50.2247  <.0001  0.4737  0.5122  *** 
#> group      0.1024  0.0116   8.7993  <.0001  0.0796  0.1252  *** 
#> quality    0.0489  0.0050   9.7741  <.0001  0.0391  0.0587  *** 
#> control    0.2076  0.0116  17.8719  <.0001  0.1848  0.2304  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
