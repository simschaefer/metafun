
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
#>   study hedges_g        z        r   se_g   se_z   mean1 mean2   sd1   sd2    n1
#>   <int>    <dbl>    <dbl>    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <dbl> <int>
#> 1     1    0.250 -0.0298  -0.0298  0.0632 0.0447  0.0441 0.291 0.967 1.01    504
#> 2     2    0.325  0.00844  0.00844 0.0344 0.0242 -0.0143 0.305 0.976 0.991  1709
#> 3     3    0.314 -0.0619  -0.0618  0.0599 0.0422 -0.0391 0.282 1.03  1.01    565
#> 4     4    0.308 -0.00203 -0.00203 0.0381 0.0268 -0.0132 0.293 1.00  0.986  1392
#> 5     5    0.589  0.141    0.140   0.0818 0.0569 -0.137  0.456 0.992 1.02    312
#> 6     6    0.215  0.00721  0.00721 0.0730 0.0517  0.0387 0.258 0.982 1.06    377
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
#> 1  0.2497 [0.1258; 0.3737]        4.6
#> 2  0.3249 [0.2574; 0.3924]       15.6
#> 3  0.3138 [0.1965; 0.4311]        5.2
#> 4  0.3082 [0.2335; 0.3830]       12.7
#> 5  0.5891 [0.4288; 0.7494]        2.8
#> 6  0.2148 [0.0716; 0.3579]        3.5
#> 7  0.2705 [0.2006; 0.3405]       14.5
#> 8  0.3048 [0.2361; 0.3735]       15.0
#> 9  0.3215 [0.2451; 0.3978]       12.2
#> 10 0.3391 [0.2680; 0.4103]       14.0
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3129 [0.2862; 0.3395] 23.02 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0278]; tau = 0.0022 [0.0000; 0.1668]
#>  I^2 = 45.0% [0.0%; 73.6%]; H = 1.35 [1.00; 1.95]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  16.38    9  0.0594
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
#> 1     1    0.631 -0.0425 -0.0425 0.0397 0.0274  0.0244  0.643 0.977 0.986  1335
#> 2     2    0.728  0.0638  0.0637 0.0412 0.0283  0.00456 0.744 1.00  1.03   1256
#> 3     3    0.790  0.0219  0.0219 0.0521 0.0355 -0.108   0.694 1.01  1.02    795
#> 4     4    0.638 -0.0202 -0.0201 0.0365 0.0252  0.0281  0.660 0.977 1.00   1581
#> 5     5    0.550  0.0325  0.0324 0.0587 0.0409  0.0467  0.601 1.01  1.01    602
#> 6     6    0.724  0.0297  0.0297 0.0445 0.0306 -0.0569  0.676 1.02  1.00   1074
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
#> 1  0.6305 [0.5528; 0.7083]       10.9
#> 2  0.7275 [0.6468; 0.8083]       10.5
#> 3  0.7899 [0.6878; 0.8920]        8.1
#> 4  0.6383 [0.5668; 0.7098]       11.8
#> 5  0.5498 [0.4348; 0.6649]        7.0
#> 6  0.7237 [0.6364; 0.8110]        9.7
#> 7  0.6445 [0.5486; 0.7403]        8.8
#> 8  0.6848 [0.6181; 0.7515]       12.5
#> 9  0.7672 [0.6689; 0.8655]        8.5
#> 10 0.6693 [0.6008; 0.7378]       12.2
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6824 [0.6357; 0.7290] 33.09 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0018 [0.0000; 0.0144]; tau = 0.0419 [0.0000; 0.1202]
#>  I^2 = 50.5% [0.0%; 76.0%]; H = 1.42 [1.00; 2.04]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  18.18    9  0.0331
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
#>   study  hedges_g     z     r   se_g   se_z    mean1    mean2   sd1   sd2    n1
#>   <int>     <dbl> <dbl> <dbl>  <dbl>  <dbl>    <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1 -0.0155   0.533 0.488 0.0422 0.0299  0.0187   0.00303 1.02  1.01   1125
#> 2     2  0.0326   0.546 0.497 0.0414 0.0293 -0.0246   0.00800 0.967 1.03   1169
#> 3     3 -0.0256   0.538 0.491 0.0321 0.0227  0.0123  -0.0128  0.986 0.975  1942
#> 4     4  0.0417   0.564 0.511 0.0415 0.0294 -0.0500  -0.00862 1.01  0.972  1162
#> 5     5 -0.0493   0.539 0.492 0.0399 0.0283  0.0103  -0.0388  1.00  0.987  1255
#> 6     6 -0.000276 0.542 0.495 0.0318 0.0225  0.00740  0.00712 0.994 1.01   1975
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
#> 1  0.4879 [0.4420; 0.5312]       10.1
#> 2  0.4972 [0.4528; 0.5392]       10.5
#> 3  0.4911 [0.4566; 0.5242]       17.4
#> 4  0.5111 [0.4673; 0.5524]       10.4
#> 5  0.4922 [0.4491; 0.5330]       11.2
#> 6  0.4947 [0.4606; 0.5273]       17.7
#> 7  0.5536 [0.4857; 0.6148]        4.0
#> 8  0.4691 [0.4080; 0.5261]        6.0
#> 9  0.4680 [0.4066; 0.5251]        6.0
#> 10 0.5304 [0.4768; 0.5800]        6.7
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.4969 [0.4828; 0.5108] 57.53       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0025]; tau = 0.0025 [0.0000; 0.0500]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  6.85    9  0.6532
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
#>   study hedges_g     z     r   se_g   se_z     mean1    mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>     <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1  -0.0221 0.505 0.466 0.0466 0.0330  0.0256    0.00337 1.00  1.01    921
#> 2     2  -0.0117 0.483 0.449 0.0412 0.0292  0.0254    0.0136  1.00  1.02   1176
#> 3     3  -0.0455 0.458 0.428 0.0734 0.0521  0.000197 -0.0457  1.03  0.988   371
#> 4     4  -0.0243 0.556 0.505 0.0366 0.0259  0.0652    0.0405  1.02  1.01   1493
#> 5     5   0.0217 0.572 0.517 0.0416 0.0295 -0.0446   -0.0235  0.982 0.964  1156
#> 6     6  -0.0239 0.381 0.363 0.0507 0.0359 -0.0152   -0.0401  1.05  1.04    779
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
#> 1  0.4661 [0.4140; 0.5152]       10.0
#> 2  0.4490 [0.4021; 0.4935]       10.3
#> 3  0.4281 [0.3411; 0.5078]        8.7
#> 4  0.5050 [0.4662; 0.5418]       10.4
#> 5  0.5171 [0.4735; 0.5581]       10.2
#> 6  0.3635 [0.3009; 0.4229]        9.8
#> 7  0.2767 [0.1988; 0.3512]        9.4
#> 8  0.4454 [0.4042; 0.4848]       10.5
#> 9  0.5432 [0.5067; 0.5778]       10.4
#> 10 0.3385 [0.2872; 0.3879]       10.3
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4385 [0.3774; 0.4958] 14.51 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0094 [0.0039; 0.0340]; tau = 0.0969 [0.0621; 0.1844]
#>  I^2 = 90.2% [84.1%; 94.0%]; H = 3.20 [2.51; 4.07]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  91.89    9 < 0.0001
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
#>   study hedges_g subgroups        z        r   se_g   se_z    mean1  mean2   sd1
#>   <int>    <dbl> <chr>        <dbl>    <dbl>  <dbl>  <dbl>    <dbl>  <dbl> <dbl>
#> 1     1   0.666  group3    -0.0154  -0.0154  0.0329 0.0226 -0.00784 0.653  1.02 
#> 2     2   0.192  group1     0.0223   0.0222  0.0333 0.0235 -0.0349  0.158  1.01 
#> 3     3   0.237  group2    -0.00406 -0.00406 0.0322 0.0227 -0.0426  0.197  1.01 
#> 4     4   0.603  group2     0.0137   0.0137  0.0413 0.0286  0.00167 0.595  0.989
#> 5     5   0.0405 group1    -0.00802 -0.00802 0.0442 0.0313  0.0110  0.0517 1.00 
#> 6     6   0.454  group2     0.0495   0.0495  0.0491 0.0343 -0.0111  0.449  1.03 
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
#> 1  0.6658 [ 0.6013; 0.7302]        3.5    group3
#> 2  0.1920 [ 0.1267; 0.2573]        3.5    group1
#> 3  0.2366 [ 0.1734; 0.2998]        3.5    group2
#> 4  0.6032 [ 0.5223; 0.6842]        3.4    group2
#> 5  0.0405 [-0.0461; 0.1271]        3.4    group1
#> 6  0.4538 [ 0.3576; 0.5500]        3.3    group2
#> 7  0.3574 [ 0.2898; 0.4251]        3.4    group2
#> 8  0.4963 [ 0.4310; 0.5616]        3.5    group1
#> 9  0.6645 [ 0.5441; 0.7850]        3.2    group1
#> 10 0.3816 [ 0.2652; 0.4981]        3.2    group3
#> 11 0.7196 [ 0.6447; 0.7945]        3.4    group3
#> 12 0.3963 [ 0.3287; 0.4638]        3.4    group2
#> 13 0.4538 [ 0.3578; 0.5499]        3.3    group3
#> 14 0.5160 [ 0.4405; 0.5915]        3.4    group2
#> 15 0.5437 [ 0.4297; 0.6577]        3.2    group2
#> 16 0.5530 [ 0.4798; 0.6262]        3.4    group3
#> 17 0.4615 [ 0.2963; 0.6267]        2.9    group2
#> 18 0.2757 [ 0.2043; 0.3472]        3.4    group1
#> 19 0.1823 [ 0.1200; 0.2445]        3.5    group1
#> 20 0.4174 [ 0.2973; 0.5375]        3.2    group2
#> 21 0.2131 [ 0.1293; 0.2969]        3.4    group2
#> 22 0.3624 [ 0.2228; 0.5019]        3.1    group1
#> 23 0.3088 [ 0.2298; 0.3879]        3.4    group3
#> 24 0.3717 [ 0.2998; 0.4436]        3.4    group2
#> 25 0.4775 [ 0.3206; 0.6344]        2.9    group2
#> 26 0.3146 [ 0.2408; 0.3883]        3.4    group2
#> 27 0.2225 [ 0.1544; 0.2906]        3.4    group1
#> 28 0.7958 [ 0.6604; 0.9313]        3.1    group3
#> 29 0.2867 [ 0.2162; 0.3571]        3.4    group1
#> 30 0.5773 [ 0.5105; 0.6440]        3.5    group3
#> 
#> Number of studies: k = 30
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.4157 [0.3496; 0.4818] 12.86 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0292 [0.0177; 0.0543]; tau = 0.1710 [0.1331; 0.2330]
#>  I^2 = 94.6% [93.3%; 95.7%]; H = 4.31 [3.85; 4.83]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  539.09   29 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                      k    SMD           95%-CI  tau^2    tau      Q   I^2
#> subgroups = group3   8 0.5561 [0.4168; 0.6954] 0.0251 0.1584  92.16 92.4%
#> subgroups = group1   9 0.2994 [0.1584; 0.4405] 0.0311 0.1763 131.07 93.9%
#> subgroups = group2  13 0.4077 [0.3371; 0.4783] 0.0118 0.1087  93.03 87.1%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                   Q d.f. p-value
#> Between groups 9.35    2  0.0093
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
               smd_true = 0.7,
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
#>   60.5656  -121.1313  -115.1313  -109.5177  -114.5858   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0.0002 (SE = 0.0007)
#> tau (square root of estimated tau^2 value):             0.0138
#> I^2 (residual heterogeneity / unaccounted variability): 4.87%
#> H^2 (unaccounted variability / sampling variability):   1.05
#> R^2 (amount of heterogeneity accounted for):            99.22%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 48) = 52.6650, p-val = 0.2984
#> 
#> Test of Moderators (coefficient 2):
#> QM(df = 1) = 299.2149, p-val < .0001
#> 
#> Model Results:
#> 
#>            estimate      se      zval    pval    ci.lb    ci.ub      
#> intrcpt      0.7193  0.0175   41.0027  <.0001   0.6849   0.7537  *** 
#> moderator   -0.5273  0.0305  -17.2978  <.0001  -0.5870  -0.4675  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

bubble(m.gen.reg, studlab = TRUE)
```

<img src="man/figures/README-unnamed-chunk-16-2.png" width="100%" />

# Multiple Metaregression

## Simulate data

``` r
data <- sim_metareg(random = TRUE,
                    tau = 0.1,
                    n_studies = 50,
                    formula = y ~ 0.1*group + 0.05*quality + 0.2*control,
                    mod_types = c('cat', 'cont', 'cat'))

head(data)
#> 
#>    hedges_g   n         se intercept group     quality control         m     yi 
#> 1 0.9264091 140 0.08807736 0.6391951     1 -0.25572028       1 1.0427260 1.0427 
#> 2 0.5417761 482 0.04561779 0.2409214     1  0.01709277       1 0.4746785 0.4747 
#> 3 0.5198031 275 0.06249976 0.5087840     0  0.22038188       0 0.4821754 0.4822 
#> 4 0.5459674 414 0.04876926 0.3615542     0 -0.31173659       1 0.5507120 0.5507 
#> 5 0.8299627 442 0.04794260 0.5806317     1 -1.01338121       1 0.7772370 0.7772 
#> 6 0.5213559 430 0.04681320 0.4566420     1 -0.70572170       0 0.4823487 0.4823 
#>       vi 
#> 1 0.0078 
#> 2 0.0021 
#> 3 0.0039 
#> 4 0.0024 
#> 5 0.0023 
#> 6 0.0022
```

## Conduct Meta-Analysis

``` r
meta <- rma(yi = hedges_g,
            sei = se,
            data = data,
            mods = ~ group + quality +control)

summary(meta)
#> 
#> Mixed-Effects Model (k = 50; tau^2 estimator: REML)
#> 
#>   logLik  deviance       AIC       BIC      AICc   
#>  39.3154  -78.6309  -68.6309  -59.4877  -67.1309   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0.0072 (SE = 0.0022)
#> tau (square root of estimated tau^2 value):             0.0847
#> I^2 (residual heterogeneity / unaccounted variability): 70.01%
#> H^2 (unaccounted variability / sampling variability):   3.33
#> R^2 (amount of heterogeneity accounted for):            64.40%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 46) = 155.0168, p-val < .0001
#> 
#> Test of Moderators (coefficients 2:4):
#> QM(df = 3) = 63.5757, p-val < .0001
#> 
#> Model Results:
#> 
#>          estimate      se     zval    pval    ci.lb   ci.ub      
#> intrcpt    0.4849  0.0251  19.3333  <.0001   0.4357  0.5340  *** 
#> group      0.1127  0.0305   3.6903  0.0002   0.0528  0.1725  *** 
#> quality    0.0209  0.0165   1.2722  0.2033  -0.0113  0.0532      
#> control    0.1879  0.0304   6.1717  <.0001   0.1282  0.2475  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```
