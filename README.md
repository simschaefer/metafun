
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
#> 1     1    0.245 0.0352  0.0480   0.297 1.00  1.03   1625  1625 0.00124
#> 2     2    0.287 0.121   0.0763   0.351 0.983 0.922   138   138 0.0146 
#> 3     3    0.264 0.0418  0.0302   0.289 0.986 0.972  1156  1156 0.00175
#> 4     4    0.239 0.0585 -0.0172   0.218 0.950 1.02    588   588 0.00343
#> 5     5    0.311 0.0564  0.00126  0.317 1.01  1.02    637   637 0.00318
#> 6     6    0.275 0.0335  0.0247   0.297 1.00  0.983  1798  1798 0.00112
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
#> 1  0.2452 [0.1762; 0.3142]       18.7
#> 2  0.2870 [0.0499; 0.5242]        1.6
#> 3  0.2641 [0.1823; 0.3460]       13.3
#> 4  0.2386 [0.1239; 0.3533]        6.8
#> 5  0.3114 [0.2009; 0.4219]        7.3
#> 6  0.2745 [0.2088; 0.3402]       20.7
#> 7  0.3945 [0.2747; 0.5143]        6.2
#> 8  0.3084 [0.2096; 0.4072]        9.2
#> 9  0.3292 [0.2323; 0.4261]        9.5
#> 10 0.2690 [0.1535; 0.3845]        6.7
#> 
#> Number of studies: k = 10
#> 
#>                        SMD           95%-CI     z  p-value
#> Common effect model 0.2835 [0.2536; 0.3134] 18.60 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0041]; tau = 0 [0.0000; 0.0639]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  6.76    9  0.6619
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
#> 1     1    0.593 0.0516  0.0795   0.686 0.990 1.05    785   785 0.00266
#> 2     2    0.525 0.0416  0.105    0.640 1.03  1.01   1195  1195 0.00173
#> 3     3    0.799 0.0381 -0.0259   0.763 0.983 0.989  1484  1484 0.00146
#> 4     4    0.660 0.0410  0.00107  0.679 1.04  1.01   1254  1254 0.00168
#> 5     5    0.857 0.0992  0.0840   0.902 0.992 0.910   222   222 0.00984
#> 6     6    0.838 0.0335 -0.0542   0.782 0.996 0.999  1944  1944 0.00112
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
#> 1  0.5930 [0.4919; 0.6941]        9.8
#> 2  0.5246 [0.4430; 0.6061]       10.6
#> 3  0.7995 [0.7247; 0.8742]       10.9
#> 4  0.6603 [0.5799; 0.7407]       10.7
#> 5  0.8573 [0.6629; 1.0517]        6.3
#> 6  0.8377 [0.7722; 0.9033]       11.2
#> 7  0.5888 [0.5075; 0.6701]       10.6
#> 8  0.6691 [0.5454; 0.7928]        8.9
#> 9  0.7016 [0.6270; 0.7761]       10.9
#> 10 0.5986 [0.5050; 0.6923]       10.1
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.6781 [0.5980; 0.7581] 19.16 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0100 [0.0036; 0.0402]; tau = 0.1002 [0.0598; 0.2005]
#>  I^2 = 85.0% [74.2%; 91.3%]; H = 2.59 [1.97; 3.39]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  60.17    9 < 0.0001
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
#> 1     1 0.552 0.502  1554 0.0254
#> 2     2 0.573 0.518   591 0.0412
#> 3     3 0.560 0.508  1075 0.0305
#> 4     4 0.550 0.501  1513 0.0257
#> 5     5 0.606 0.541   809 0.0352
#> 6     6 0.557 0.506   216 0.0685
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
#> 1  0.5021 [0.4640; 0.5384]       17.4
#> 2  0.5176 [0.4559; 0.5742]        6.6
#> 3  0.5076 [0.4619; 0.5507]       12.1
#> 4  0.5006 [0.4618; 0.5374]       17.0
#> 5  0.5413 [0.4907; 0.5883]        9.1
#> 6  0.5061 [0.3996; 0.5991]        2.4
#> 7  0.5370 [0.4660; 0.6012]        4.8
#> 8  0.4810 [0.4334; 0.5259]       11.9
#> 9  0.4816 [0.4241; 0.5352]        8.3
#> 10 0.4846 [0.4339; 0.5322]       10.5
#> 
#> Number of studies: k = 10
#> 
#>                        COR           95%-CI     z p-value
#> Common effect model 0.5030 [0.4873; 0.5184] 52.18       0
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0 [0.0000; 0.0014]; tau = 0 [0.0000; 0.0369]
#>  I^2 = 0.0% [0.0%; 62.4%]; H = 1.00 [1.00; 1.63]
#> 
#> Test of heterogeneity:
#>     Q d.f. p-value
#>  5.49    9  0.7901
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
#> 1     1 0.636 0.562  1223 0.0286
#> 2     2 0.449 0.421  1467 0.0261
#> 3     3 0.485 0.451  1208 0.0288
#> 4     4 0.288 0.281  1223 0.0286
#> 5     5 0.513 0.472  1364 0.0271
#> 6     6 0.704 0.607   670 0.0387
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
#> 1  0.5621 [0.5226; 0.5993]       10.0
#> 2  0.4208 [0.3777; 0.4620]       10.2
#> 3  0.4505 [0.4044; 0.4944]       10.0
#> 4  0.2807 [0.2282; 0.3315]       10.0
#> 5  0.4719 [0.4296; 0.5122]       10.1
#> 6  0.6066 [0.5565; 0.6524]        9.5
#> 7  0.5298 [0.4939; 0.5638]       10.2
#> 8  0.4248 [0.3745; 0.4725]       10.0
#> 9  0.4718 [0.4354; 0.5066]       10.3
#> 10 0.4381 [0.3775; 0.4951]        9.6
#> 
#> Number of studies: k = 10
#> 
#>                              COR           95%-CI     t  p-value
#> Random effects model (HK) 0.4694 [0.4035; 0.5305] 14.14 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0120 [0.0052; 0.0427]; tau = 0.1093 [0.0719; 0.2065]
#>  I^2 = 92.8% [88.8%; 95.4%]; H = 3.73 [2.99; 4.65]
#> 
#> Test of heterogeneity:
#>       Q d.f.  p-value
#>  125.20    9 < 0.0001
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
         n_studies = 10,
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
#> 1     1    0.512 group1   0.0421  0.124   0.628 0.965 1.00   1163  1163 0.00178
#> 2     2    0.691 group2   0.0422  0.0276  0.715 0.971 1.02   1190  1190 0.00178
#> 3     3    0.942 group2   0.0979  0.0390  0.985 0.984 1.02    232   232 0.00958
#> 4     4    0.782 group2   0.0339  0.0235  0.805 1.02  0.978  1870  1870 0.00115
#> 5     5    0.768 group1   0.0518 -0.228   0.557 1.02  1.02    799   799 0.00269
#> 6     6    0.761 group2   0.0348  0.0351  0.806 1.02  1.00   1769  1769 0.00121
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
#> 1  0.5122 [0.4296; 0.5948]       10.7   group1
#> 2  0.6907 [0.6080; 0.7734]       10.7   group2
#> 3  0.9424 [0.7505; 1.1342]        7.7   group2
#> 4  0.7823 [0.7158; 0.8488]       11.1   group2
#> 5  0.7675 [0.6659; 0.8691]       10.3   group1
#> 6  0.7612 [0.6929; 0.8294]       11.0   group2
#> 7  0.9240 [0.7795; 1.0686]        9.1   group2
#> 8  0.5806 [0.4023; 0.7588]        8.1   group2
#> 9  0.8125 [0.7351; 0.8900]       10.8   group2
#> 10 0.9804 [0.8855; 1.0753]       10.4   group2
#> 
#> Number of studies: k = 10
#> 
#>                              SMD           95%-CI     t  p-value
#> Random effects model (HK) 0.7725 [0.6658; 0.8791] 16.39 < 0.0001
#> 
#> Quantifying heterogeneity:
#>  tau^2 = 0.0185 [0.0072; 0.0727]; tau = 0.1360 [0.0846; 0.2696]
#>  I^2 = 87.6% [79.2%; 92.6%]; H = 2.84 [2.19; 3.68]
#> 
#> Test of heterogeneity:
#>      Q d.f.  p-value
#>  72.54    9 < 0.0001
#> 
#> Results for subgroups (random effects model (HK)):
#>                     k    SMD            95%-CI  tau^2    tau     Q   I^2
#> subgroup = group1   2 0.6381 [-0.9843; 2.2604] 0.0304 0.1743 14.61 93.2%
#> subgroup = group2   8 0.8080 [ 0.7013; 0.9147] 0.0116 0.1075 32.94 78.7%
#> 
#> Test for subgroup differences (random effects model (HK)):
#>                   Q d.f. p-value
#> Between groups 1.57    1  0.2096
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
