
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
#>   study hedges_g        z        r   se_g   se_z    mean1 mean2   sd1   sd2
#>   <int>    <dbl>    <dbl>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1     1    0.306 -0.0225  -0.0225  0.0375 0.0264 -0.00458 0.297 0.985 0.987
#> 2     2    0.290 -0.00450 -0.00450 0.0628 0.0443 -0.0473  0.230 0.985 0.927
#> 3     3    0.239  0.0449   0.0448  0.0636 0.0449 -0.00336 0.235 0.970 1.02 
#> 4     4    0.294 -0.0168  -0.0168  0.0468 0.0330  0.00925 0.298 1.01  0.955
#> 5     5    0.253 -0.143   -0.142   0.163  0.117   0.00696 0.256 0.986 0.975
#> 6     6    0.273 -0.0318  -0.0318  0.0403 0.0284 -0.00228 0.275 0.999 1.03 
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
#> 1  0.3059 [ 0.2324; 0.3793]       20.0
#> 2  0.2895 [ 0.1664; 0.4127]        7.1
#> 3  0.2386 [ 0.1140; 0.3633]        6.9
#> 4  0.2940 [ 0.2022; 0.3858]       12.8
#> 5  0.2531 [-0.0662; 0.5723]        1.1
#> 6  0.2730 [ 0.1940; 0.3519]       17.3
#> 7  0.2858 [ 0.0944; 0.4771]        2.9
#> 8  0.3518 [ 0.2796; 0.4239]       20.7
#> 9  0.2248 [ 0.0691; 0.3805]        4.4
#> 10 0.2587 [ 0.1320; 0.3853]        6.7
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2944 [0.2616; 0.3272] 17.57 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0016]; tau = 0 [0.0000; 0.0398]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  4.73    9  0.8575
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
#>   study hedges_g        z        r   se_g   se_z    mean1 mean2   sd1   sd2
#>   <int>    <dbl>    <dbl>    <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl> <dbl>
#> 1     1    0.700  0.0115   0.0115  0.0449 0.0308 -0.0277  0.671 1.01  0.983
#> 2     2    0.628 -0.00447 -0.00447 0.0330 0.0228 -0.0121  0.618 0.996 1.01 
#> 3     3    0.699 -0.0213  -0.0213  0.0361 0.0248 -0.00848 0.703 1.02  1.01 
#> 4     4    0.667 -0.0105  -0.0105  0.0419 0.0289 -0.00247 0.673 1.01  1.02 
#> 5     5    0.689  0.0464   0.0463  0.0326 0.0224  0.00468 0.688 0.968 1.01 
#> 6     6    0.695 -0.0689  -0.0688  0.0531 0.0366 -0.0230  0.693 1.03  1.03 
#> # ℹ 4 more variables: n1 <int>, n2 <int>, n <int>, variance_g <dbl>
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
#> 1  0.7000 [0.6120; 0.7879]        9.0
#> 2  0.6278 [0.5632; 0.6925]       15.1
#> 3  0.6989 [0.6280; 0.7697]       13.0
#> 4  0.6668 [0.5848; 0.7489]       10.1
#> 5  0.6893 [0.6255; 0.7532]       15.4
#> 6  0.6950 [0.5908; 0.7991]        6.6
#> 7  0.6616 [0.5607; 0.7625]        7.0
#> 8  0.8447 [0.6621; 1.0273]        2.3
#> 9  0.6646 [0.5886; 0.7406]       11.6
#> 10 0.5724 [0.4894; 0.6553]        9.9
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6675 [0.6321; 0.7029] 42.63 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0003 [0.0000; 0.0106]; tau = 0.0165 [0.0000; 0.1031]
#>  I^2 = 25.8% [0.0%; 64.2%]; H = 1.16 [1.00; 1.67]
#> 
#> Test of heterogeneity:
#>      Q d.f. p-value
#>  12.13    9  0.2063
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
#>   study hedges_g     z     r   se_g   se_z    mean1    mean2   sd1   sd2    n1
#>   <int>    <dbl> <dbl> <dbl>  <dbl>  <dbl>    <dbl>    <dbl> <dbl> <dbl> <int>
#> 1     1   0.0220 0.557 0.506 0.0471 0.0333  0.00433  0.0266  0.998 1.02    903
#> 2     2  -0.0360 0.552 0.502 0.0347 0.0245  0.0158  -0.0201  0.988 1.00   1666
#> 3     3  -0.0364 0.541 0.494 0.0406 0.0288  0.0249  -0.0104  0.962 0.974  1212
#> 4     4   0.0403 0.506 0.467 0.0567 0.0402 -0.0210   0.0200  1.04  0.993   623
#> 5     5   0.0208 0.588 0.529 0.0357 0.0253 -0.0458  -0.0247  0.999 1.03   1569
#> 6     6  -0.0120 0.526 0.482 0.0365 0.0258  0.00877 -0.00309 1.02  0.965  1500
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
#> 1  0.5056 [0.4554; 0.5526]        6.8
#> 2  0.5021 [0.4653; 0.5372]       12.6
#> 3  0.4937 [0.4499; 0.5351]        9.1
#> 4  0.4671 [0.4034; 0.5264]        4.7
#> 5  0.5286 [0.4920; 0.5633]       11.8
#> 6  0.4823 [0.4425; 0.5202]       11.3
#> 7  0.4788 [0.4305; 0.5243]        7.8
#> 8  0.4959 [0.4556; 0.5341]       10.7
#> 9  0.4830 [0.4481; 0.5164]       14.6
#> 10 0.4689 [0.4269; 0.5088]       10.5
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.4922 [0.4792; 0.5050] 62.00       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0012]; tau = 0 [0.0000; 0.0352]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  7.20    9  0.6167
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
#> 1     1  0.00195 0.765 0.644 0.0826 0.0587  0.0207   0.0227  1.02  0.965   293
#> 2     2 -0.0405  0.260 0.254 0.0383 0.0271  0.00169 -0.0385  1.00  0.984  1363
#> 3     3  0.0277  0.564 0.511 0.0369 0.0261  0.0228   0.0507  1.01  1.00   1469
#> 4     4  0.0106  0.438 0.412 0.0343 0.0243 -0.0121  -0.00156 1.00  0.984  1699
#> 5     5  0.00411 0.547 0.499 0.0430 0.0304 -0.0290  -0.0249  0.998 0.999  1084
#> 6     6  0.0371  0.473 0.441 0.0367 0.0260 -0.0374  -0.00109 0.970 0.988  1487
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
#> 1  0.6440 [0.5715; 0.7064]        9.1
#> 2  0.2541 [0.2037; 0.3031]       10.5
#> 3  0.5107 [0.4719; 0.5475]       10.5
#> 4  0.4119 [0.3716; 0.4506]       10.6
#> 5  0.4986 [0.4525; 0.5420]       10.4
#> 6  0.4408 [0.3989; 0.4808]       10.5
#> 7  0.5323 [0.4626; 0.5954]        9.7
#> 8  0.3124 [0.1934; 0.4223]        8.8
#> 9  0.4428 [0.3653; 0.5142]        9.7
#> 10 0.4177 [0.3594; 0.4728]       10.2
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4516 [0.3690; 0.5271] 11.08 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0170 [0.0072; 0.0646]; tau = 0.1304 [0.0850; 0.2541]
#>  I^2 = 92.4% [88.1%; 95.2%]; H = 3.63 [2.90; 4.54]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  118.78    9 < 0.0001
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
#>   study hedges_g subgroups       z       r   se_g   se_z    mean1 mean2   sd1
#>   <int>    <dbl> <chr>       <dbl>   <dbl>  <dbl>  <dbl>    <dbl> <dbl> <dbl>
#> 1     1   0.0807 group1    -0.0131 -0.0131 0.0459 0.0325  0.0473  0.129 0.993
#> 2     2   0.221  group1     0.0183  0.0183 0.0376 0.0265  0.0516  0.277 1.01 
#> 3     3   0.260  group1     0.0326  0.0326 0.0443 0.0312  0.0230  0.282 0.996
#> 4     4   0.216  group1     0.0429  0.0429 0.0517 0.0365 -0.00600 0.210 1.05 
#> 5     5   0.469  group2     0.0311  0.0311 0.0405 0.0283  0.00395 0.470 1.01 
#> 6     6   0.284  group3     0.0249  0.0249 0.0389 0.0274  0.0197  0.303 0.986
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
#> 1  0.0807 [-0.0094; 0.1707]        3.4    group1
#> 2  0.2210 [ 0.1473; 0.2948]        3.5    group1
#> 3  0.2599 [ 0.1730; 0.3468]        3.4    group1
#> 4  0.2164 [ 0.1151; 0.3176]        3.3    group1
#> 5  0.4694 [ 0.3902; 0.5487]        3.4    group2
#> 6  0.2841 [ 0.2078; 0.3604]        3.4    group3
#> 7  0.4319 [ 0.3345; 0.5293]        3.3    group2
#> 8  0.2872 [ 0.1623; 0.4120]        3.1    group2
#> 9  0.6071 [ 0.5360; 0.6781]        3.5    group3
#> 10 0.6082 [ 0.5243; 0.6922]        3.4    group2
#> 11 0.1718 [ 0.1030; 0.2406]        3.5    group2
#> 12 0.4760 [ 0.3455; 0.6065]        3.1    group3
#> 13 0.4127 [ 0.2425; 0.5828]        2.7    group1
#> 14 0.3212 [ 0.2452; 0.3971]        3.4    group2
#> 15 0.2165 [ 0.1304; 0.3026]        3.4    group1
#> 16 0.4972 [ 0.4312; 0.5632]        3.5    group3
#> 17 0.4237 [ 0.2704; 0.5771]        2.9    group3
#> 18 0.3569 [ 0.2610; 0.4528]        3.3    group2
#> 19 0.5527 [ 0.4620; 0.6435]        3.4    group3
#> 20 0.3133 [ 0.2356; 0.3910]        3.4    group1
#> 21 0.4825 [ 0.3780; 0.5871]        3.3    group2
#> 22 0.4193 [ 0.3447; 0.4938]        3.5    group2
#> 23 0.1706 [ 0.0948; 0.2464]        3.4    group1
#> 24 0.6241 [ 0.5585; 0.6898]        3.5    group3
#> 25 0.5199 [ 0.4470; 0.5928]        3.5    group3
#> 26 0.4038 [ 0.3285; 0.4791]        3.4    group3
#> 27 0.6024 [ 0.5322; 0.6726]        3.5    group3
#> 28 0.4918 [ 0.3327; 0.6508]        2.8    group3
#> 29 0.4263 [ 0.3500; 0.5027]        3.4    group3
#> 30 0.6366 [ 0.5654; 0.7079]        3.5    group3
#> 
#> Number of studies: k = 30
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.3995 [0.3418; 0.4571] 14.17 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0221 [0.0130; 0.0404]; tau = 0.1487 [0.1142; 0.2010]
#>  I^2 = 93.2% [91.3%; 94.6%]; H = 3.82 [3.38; 4.32]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  423.37   29 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                      k    SMD           95%-CI  tau^2    tau     Q   I^2
#> subgroups = group1   8 0.2263 [0.1524; 0.3002] 0.0046 0.0681 22.12 68.4%
#> subgroups = group2   9 0.3942 [0.2957; 0.4926] 0.0146 0.1210 78.83 89.9%
#> subgroups = group3  13 0.5068 [0.4432; 0.5705] 0.0096 0.0978 85.66 86.0%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                    Q d.f.  p-value
#> Between groups 43.17    2 < 0.0001
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
#>   64.5945  -129.1891  -123.1891  -117.5755  -122.6436   
#> 
#> tau^2 (estimated amount of residual heterogeneity):     0 (SE = 0.0007)
#> tau (square root of estimated tau^2 value):             0
#> I^2 (residual heterogeneity / unaccounted variability): 0.00%
#> H^2 (unaccounted variability / sampling variability):   1.00
#> R^2 (amount of heterogeneity accounted for):            100.00%
#> 
#> Test for Residual Heterogeneity:
#> QE(df = 48) = 44.8338, p-val = 0.6034
#> 
#> Test of Moderators (coefficient 2):
#> QM(df = 1) = 288.9802, p-val < .0001
#> 
#> Model Results:
#> 
#>            estimate      se      zval    pval    ci.lb    ci.ub      
#> intrcpt      0.0116  0.0158    0.7379  0.4606  -0.0193   0.0426      
#> moderator   -0.5102  0.0300  -16.9994  <.0001  -0.5690  -0.4514  *** 
#> 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

bubble(m.gen.reg, studlab = TRUE)
```

<img src="man/figures/README-unnamed-chunk-16-2.png" width="100%" />
