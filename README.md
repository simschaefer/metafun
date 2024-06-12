
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
#>   study hedges_g        z        r   se_g   se_z     mean1 mean2   sd1   sd2
#>   <int>    <dbl>    <dbl>    <dbl>  <dbl>  <dbl>     <dbl> <dbl> <dbl> <dbl>
#> 1     1    0.342  0.0308   0.0308  0.0445 0.0313  0.0109   0.363 1.04  1.01 
#> 2     2    0.305 -0.0135  -0.0135  0.0693 0.0489 -0.0224   0.279 0.990 0.987
#> 3     3    0.568  0.0478   0.0477  0.109  0.0762 -0.0921   0.463 1.02  0.927
#> 4     4    0.271 -0.0264  -0.0264  0.0622 0.0439 -0.000491 0.272 0.937 1.07 
#> 5     5    0.357  0.0237   0.0237  0.0345 0.0243 -0.0191   0.334 0.998 0.979
#> 6     6    0.308 -0.00510 -0.00510 0.0422 0.0297 -0.0340   0.278 1.03  0.998
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
#> 1  0.3418 [0.2546; 0.4291]       10.8
#> 2  0.3050 [0.1691; 0.4409]        4.5
#> 3  0.5676 [0.3538; 0.7813]        1.8
#> 4  0.2705 [0.1486; 0.3924]        5.6
#> 5  0.3568 [0.2891; 0.4245]       18.0
#> 6  0.3080 [0.2253; 0.3907]       12.1
#> 7  0.2605 [0.1774; 0.3436]       12.0
#> 8  0.3050 [0.2052; 0.4048]        8.3
#> 9  0.3060 [0.2358; 0.3761]       16.8
#> 10 0.3112 [0.2218; 0.4006]       10.3
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.3170 [0.2883; 0.3457] 21.63 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 < 0.0001 [0.0000; 0.0156]; tau = 0.0026 [0.0000; 0.1248]
#>  I^2 = 5.2% [0.0%; 64.3%]; H = 1.03 [1.00; 1.67]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  9.50    9  0.3928
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
#> 1     1    0.687 -0.0237  -0.0237  0.0382 0.0263  0.0261 0.708 0.993 0.994  1450
#> 2     2    0.786  0.0229   0.0229  0.0468 0.0320 -0.0114 0.792 1.01  1.03    982
#> 3     3    0.811 -0.0165  -0.0165  0.0354 0.0241 -0.0689 0.748 1.01  1.00   1726
#> 4     4    0.636 -0.0182  -0.0182  0.0375 0.0259 -0.0174 0.612 0.989 0.991  1492
#> 5     5    0.645 -0.0418  -0.0418  0.0386 0.0267 -0.0212 0.626 1.01  0.997  1411
#> 6     6    0.616 -0.00135 -0.00135 0.0439 0.0304  0.0977 0.733 1.03  1.03   1086
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
#> 1  0.6866 [0.6117; 0.7615]       10.5
#> 2  0.7863 [0.6945; 0.8781]        9.4
#> 3  0.8112 [0.7418; 0.8806]       10.8
#> 4  0.6356 [0.5620; 0.7091]       10.6
#> 5  0.6454 [0.5697; 0.7211]       10.4
#> 6  0.6156 [0.5295; 0.7017]        9.8
#> 7  0.6740 [0.5183; 0.8297]        6.1
#> 8  0.5959 [0.5313; 0.6606]       11.1
#> 9  0.8059 [0.7290; 0.8828]       10.4
#> 10 0.7300 [0.6625; 0.7976]       10.9
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6991 [0.6407; 0.7576] 27.06 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0052 [0.0015; 0.0199]; tau = 0.0721 [0.0392; 0.1409]
#>  I^2 = 77.5% [58.8%; 87.8%]; H = 2.11 [1.56; 2.86]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  40.08    9 < 0.0001
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
#> 1     1  0.0278  0.587 0.528 0.0528 0.0374 -0.0155   0.0122 1.02  0.976   717
#> 2     2  0.0627  0.578 0.521 0.0831 0.0590 -0.0166   0.0499 1.06  1.06    290
#> 3     3  0.00233 0.550 0.500 0.0400 0.0283 -0.0259  -0.0236 0.996 0.992  1251
#> 4     4  0.00377 0.569 0.515 0.0664 0.0471 -0.0186  -0.0146 1.04  1.08    453
#> 5     5  0.0511  0.566 0.512 0.0378 0.0268  0.00464  0.0568 1.01  1.03   1397
#> 6     6  0.0142  0.481 0.447 0.0854 0.0607 -0.00148  0.0126 0.986 0.989   274
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
#> 1  0.5277 [0.4728; 0.5786]        6.9
#> 2  0.5212 [0.4319; 0.6003]        2.8
#> 3  0.5004 [0.4577; 0.5408]       12.1
#> 4  0.5147 [0.4436; 0.5793]        4.4
#> 5  0.5121 [0.4723; 0.5498]       13.5
#> 6  0.4473 [0.3472; 0.5373]        2.6
#> 7  0.4786 [0.4440; 0.5117]       19.4
#> 8  0.5071 [0.4355; 0.5723]        4.4
#> 9  0.5146 [0.4788; 0.5487]       16.5
#> 10 0.5012 [0.4657; 0.5351]       17.4
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.5024 [0.4878; 0.5167] 56.07       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0010]; tau = 0 [0.0000; 0.0319]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  5.22    9  0.8145
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
#>   study hedges_g     z     r   se_g   se_z   mean1     mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>   <dbl>     <dbl> <dbl> <dbl> <int>
#> 1     1  0.0209  0.598 0.536 0.0393 0.0278 -0.0213 -0.000420 1.00  1.00   1298
#> 2     2 -0.00148 0.558 0.506 0.0645 0.0458  0.0425  0.0410   1.06  0.989   480
#> 3     3 -0.0490  0.411 0.389 0.0509 0.0360  0.0602  0.0110   0.969 1.04    773
#> 4     4  0.0876  0.388 0.369 0.0418 0.0296 -0.0409  0.0480   0.991 1.04   1147
#> 5     5 -0.0251  0.556 0.505 0.0690 0.0490  0.0411  0.0166   0.969 0.981   420
#> 6     6  0.0105  0.509 0.470 0.0365 0.0259  0.0221  0.0327   0.996 1.01   1498
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
#> 1  0.5358 [0.4958; 0.5735]       10.9
#> 2  0.5064 [0.4367; 0.5701]        9.2
#> 3  0.3889 [0.3274; 0.4472]       10.1
#> 4  0.3695 [0.3184; 0.4184]       10.7
#> 5  0.5049 [0.4300; 0.5729]        8.9
#> 6  0.4696 [0.4291; 0.5081]       11.0
#> 7  0.5150 [0.4638; 0.5627]       10.3
#> 8  0.3868 [0.2975; 0.4695]        8.6
#> 9  0.4615 [0.4183; 0.5026]       10.9
#> 10 0.5737 [0.5146; 0.6273]        9.5
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4735 [0.4230; 0.5210] 18.42 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0064 [0.0023; 0.0248]; tau = 0.0797 [0.0480; 0.1576]
#>  I^2 = 83.6% [71.4%; 90.6%]; H = 2.47 [1.87; 3.26]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  54.87    9 < 0.0001
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
#>   study hedges_g subgroups       z       r   se_g   se_z   mean1 mean2   sd1
#>   <int>    <dbl> <chr>       <dbl>   <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>
#> 1     1   0.526  group3     0.0316  0.0315 0.0391 0.0272 -0.176  0.352 1.01 
#> 2     2   0.478  group1     0.0687  0.0686 0.0545 0.0381 -0.245  0.229 0.981
#> 3     3   0.451  group3    -0.0651 -0.0650 0.0974 0.0685  0.146  0.600 0.953
#> 4     4   0.499  group3     0.0381  0.0380 0.0340 0.0237  0.0270 0.546 1.02 
#> 5     5   0.0294 group1    -0.0246 -0.0246 0.0317 0.0224  0.135  0.164 1.01 
#> 6     6   0.493  group2    -0.124  -0.123  0.0837 0.0586 -0.0401 0.434 0.978
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
#> 1  0.5262 [ 0.4495; 0.6028]        3.5    group3
#> 2  0.4777 [ 0.3709; 0.5845]        3.3    group1
#> 3  0.4513 [ 0.2603; 0.6423]        2.7    group3
#> 4  0.4995 [ 0.4330; 0.5660]        3.6    group3
#> 5  0.0294 [-0.0327; 0.0915]        3.6    group1
#> 6  0.4927 [ 0.3286; 0.6568]        2.9    group2
#> 7  0.2581 [ 0.1859; 0.3302]        3.5    group3
#> 8  0.3008 [ 0.2105; 0.3911]        3.4    group2
#> 9  0.4671 [ 0.3950; 0.5392]        3.5    group3
#> 10 0.6399 [ 0.5688; 0.7110]        3.5    group3
#> 11 0.0624 [-0.0439; 0.1686]        3.3    group1
#> 12 0.2730 [ 0.1655; 0.3806]        3.3    group3
#> 13 0.3435 [ 0.2805; 0.4064]        3.6    group3
#> 14 0.2272 [ 0.1158; 0.3385]        3.3    group3
#> 15 0.2748 [ 0.2077; 0.3419]        3.6    group3
#> 16 0.0893 [ 0.0248; 0.1537]        3.6    group2
#> 17 0.4030 [ 0.3140; 0.4919]        3.4    group1
#> 18 0.4108 [ 0.3188; 0.5028]        3.4    group2
#> 19 0.3225 [ 0.1495; 0.4956]        2.8    group2
#> 20 0.7069 [ 0.6306; 0.7833]        3.5    group3
#> 21 0.3175 [ 0.1537; 0.4813]        2.9    group1
#> 22 0.5410 [ 0.3825; 0.6995]        2.9    group3
#> 23 0.3373 [ 0.2355; 0.4391]        3.4    group2
#> 24 0.3145 [ 0.1515; 0.4774]        2.9    group2
#> 25 0.4138 [ 0.3364; 0.4913]        3.5    group2
#> 26 0.3313 [ 0.2600; 0.4026]        3.5    group1
#> 27 0.3492 [ 0.2828; 0.4156]        3.6    group2
#> 28 0.4781 [ 0.2877; 0.6685]        2.7    group2
#> 29 0.6175 [ 0.5450; 0.6901]        3.5    group3
#> 30 0.2568 [ 0.1825; 0.3312]        3.5    group1
#> 
#> Number of studies: k = 30
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.3722 [0.3113; 0.4331] 12.50 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0246 [0.0143; 0.0444]; tau = 0.1570 [0.1197; 0.2108]
#>  I^2 = 94.1% [92.5%; 95.3%]; H = 4.10 [3.65; 4.61]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  488.40   29 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                      k    SMD           95%-CI  tau^2    tau      Q   I^2
#> subgroups = group3  13 0.4486 [0.3510; 0.5461] 0.0242 0.1555 188.78 93.6%
#> subgroups = group1   7 0.2660 [0.1103; 0.4218] 0.0262 0.1620  94.08 93.6%
#> subgroups = group2  10 0.3415 [0.2578; 0.4252] 0.0112 0.1061  65.96 86.4%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                   Q d.f. p-value
#> Between groups 6.30    2  0.0428
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
#>   58.7799  -117.5597  -111.5597  -105.9461  -111.0143   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0.0005 (SE = 0.0008)
#> tau (square root of estimated tau^2 value):             0.0216
#> I^2 (residual heterogeneity / unaccounted variability): 10.96%
#> H^2 (unaccounted variability / sampling variability):   1.12
#> R^2 (amount of heterogeneity accounted for):            98.02%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 48) = 54.6645, p-val = 0.2363
#> 
#> Test of Moderators (coefficient 2):
#> QM(df = 1) = 280.2488, p-val < .0001
#> 
#> Model Results:
#> 
#>            estimate      se      zval    pval    ci.lb    ci.ub      
#> intrcpt      0.0138  0.0175    0.7888  0.4302  -0.0205   0.0480      
#> moderator   -0.5074  0.0303  -16.7406  <.0001  -0.5668  -0.4480  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

bubble(m.gen.reg, studlab = TRUE)
```

<img src="man/figures/README-unnamed-chunk-16-2.png" width="100%" />
