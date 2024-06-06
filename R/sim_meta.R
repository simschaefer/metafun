#' sim_meta
#'
#' @param min_obs minimum number of observations per study
#' @param max_obs maximum number of observations per study
#' @param n_studies number of studies
#' @param es_true true effect size
#' @param es type of effect size (choose 'SMD' fpr standardized mean difference and 'ZCOR' for correlations)
#' @param fixed simulation based on fixed effects model (TRUE)
#' @param random simulation based on between study heterogenity (random-effects model)
#' @param tau specify standard deviation of between study heterogenity
#' @param varnames variable names
#'
#' @return list containing raw data (data_raw) and aggregated data with computed effects sizes and standard errors (data_aggr)
#' @export
#' @importFrom psych fisherz
#' @importFrom metafor escalc
#' @importFrom faux rnorm_multi
#' @importFrom dplyr summarise bind_rows group_by %>% mutate sym tibble rename select
#' @importFrom stats cor rnorm sd setNames
#' @examples
#' sim_meta(min_obs = 100, max_obs = 500, n_studies = 20, es_true = 0.7)
#'
sim_meta <- function(min_obs,
                     max_obs,
                     n_studies,
                     es_true,
                     es = 'SMD',
                     fixed = TRUE,
                     random = FALSE,
                     tau = 0.01,
                     varnames = c('x','y')
                     ){

  data_list <- list()

  if(es == 'SMD'){
      # mean Group 1
      mean2 <- 0

      # mean Group 2
      mean1 <- mean2 + es_true

      for(i in 1:n_studies){
        n <- sample(min_obs:max_obs, 1)

        if(random){
          study_mean1 <- rnorm(1, mean = mean1, sd = tau)
          study_mean2 <- rnorm(1, mean = mean2, sd = tau)
        }else if(fixed){
          study_mean1 = mean1
          study_mean2 = mean2
        }

        data_list[[i]] <- data.frame('x' = rnorm(n,
                                                     study_mean1,
                                                     1),
                                     'y' = rnorm(n,
                                                  study_mean2,
                                                  1)) %>%
          mutate(study = i)

        colnames(data_list[[i]]) <- c(varnames, 'study')
      }

      data_raw <- data_list %>%
        bind_rows()

      data_raw <- data_raw %>%
        group_by(study) %>%
        summarise(mean1 = mean(!!sym(varnames[1])),
                  mean2 = mean(!!sym(varnames[2])),
                  sd1 = sd(!!sym(varnames[1])),
                  sd2 = sd(!!sym(varnames[2])),
                  n1 = length(!!sym(varnames[1])),
                  n2 = length(!!sym(varnames[2])))

      nam <- c("mean", "mean", "sd", "sd", "n", "n")
      lookup <- paste0(nam, c(1,2))
      new_names <- paste0(nam,"_", varnames)

      data_aggr <- escalc(data = data_raw,
                       measure = 'SMD',
                       m1i = mean1,
                       m2i = mean2,
                       sd1i = sd1,
                       sd2i = sd2,
                       n1i = n1,
                       n2i = n2) %>%
        mutate(se = sqrt(vi)) %>%
        rename(!!!setNames(lookup, new_names)) %>%
        rename(hedges_g = yi) %>%
        tibble() %>%
        select(study, hedges_g,se, everything())

  }else if(es == 'ZCOR'){

    for(i in 1:n_studies){
      n <- sample(min_obs:max_obs, 1)

      if(fixed){
        r_true <- es_true
      }else if(random){
        r_true <- rnorm(1, es_true, tau)
      }

      data_list[[i]] <- data.frame(rnorm_multi(n,
                                               2,
                                               r = r_true,
                                               varnames = varnames)) %>%
        mutate(study = i)
    }

    data_raw <- data_list %>%
      bind_rows()

    data_aggr <- data_raw %>%
      group_by(study) %>%
      summarise(r = cor(!!sym(varnames[1]),
                        !!sym(varnames[2])),
                z = fisherz(r),
                n = length(!!sym(varnames[1])),
                se = 1/sqrt(n-3)) %>%
      select(study, r,z,n,se, everything())
    }

    return_list <- list(data_raw = data_raw,
                      data_aggr = data_aggr,
                      es_true = es_true,
                      tau = tau)

    return(return_list)
  }

