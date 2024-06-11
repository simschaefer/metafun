#' sim_meta
#'
#' @param min_obs minimum number of observations per study
#' @param max_obs maximum number of observations per study
#' @param n_studies number of studies
#' @param es_true true effect size
#' @param es type of effect size (choose 'SMD' fpr standardized mean difference and 'ZCOR' for correlations)
#' @param fixed simulation based on fixed effects model (TRUE)
#' @param random simulation based on between study heterogenity (random-effects model)
#' @param tau specify standard deviation of between study heterogenity. If moderator variable specified, tau is the residual heterogenity after including the moderator.
#' @param varnames variable names
#' @param n_variance variance between n1 and n2. Both sample sizes are drawn from normal distributions using the specified value as standard deviation.
#' @param metaregression set TRUE if categorical or continuous moderator should be included.
#' @param mod_varname specify the variable name of the moderator
#' @param mod_labels specify the labels of different groups of studies, if the moderator is a categorical variable.
#' @param mod_effect standardize size of moderation effect for categorical moderator. Provide a vector of multiple effect sizes if moderator variable includes more than two groups.
#' @param aggregate return only aggregated data (TRUE) or list containing raw data (FALSE).
#'
#' @return list containing raw data (data_raw) and aggregated data with computed effects sizes and standard errors (data_aggr)
#' @export
#' @importFrom psych fisherz
#' @importFrom metafor escalc
#' @importFrom tidyr unnest
#' @importFrom faux rnorm_multi
#' @importFrom dplyr summarise bind_rows group_by %>% mutate sym tibble rename select
#' @importFrom purrr map
#' @importFrom stats cor rnorm sd setNames
#' @examples
#' sim_meta(min_obs = 100, max_obs = 500, n_studies = 20, es_true = 0.7)

sim_meta <- function(min_obs,
                     max_obs,
                     n_studies,
                     es_true,
                     es = 'SMD',
                     fixed = TRUE,
                     random = FALSE,
                     tau = 0.01,
                     varnames = c('x','y'),
                     n_variance = 0,
                     metaregression = FALSE,
                     mod_varname = c(),
                     mod_labels = c(),
                     mod_effect = NA,
                     aggregate = TRUE
                     ){

  if(!metaregression){
    mod_effect <- 0
  }else{
    if(length(mod_labels)-1 > length(mod_effect)){
      stop('Number of subgroups is higher than number of effect sizes in `mod_effect`.')
    }else if(length(mod_labels) <= length(mod_effect)){
      n_effects <- length(mod_effect)
      n_labels <- length(mod_labels)
      warning(paste0('Number of moderator labels (',n_labels,') does not match the number of effect sizes (',n_effects,'). Only the first ',n_labels-1,' effect sizes are used.'))
    }
  }

  if(length(varnames) > 2){
    warning(paste0('Number of variable names is too large (',length(varnames),'). Only the first two names are used.'))
    varnames <- varnames[1:2]
  }else if(length(varnames) == 1){
    warning("You only specified one variable name. The second variable is called 'y'.")
    varnames <- c(varnames, 'y')
  }else{
    varnames <- c('x', 'y')
  }

  if(min_obs > max_obs){
    warning('Minimum number of observations is lower than maximum. Please adjust `min_obs` and `max_obs`.')
  }

  if(fixed & random){
    message('Both fixed and random were chosen. Only random-effects model is applied.')
  }

  if(n_variance > 0 & es == 'ZCOR'){
    message('n_variance is ignored because of within sample effect size.')
  }

  data_list <- list()

  if(es == 'SMD'){
      # mean Group 1
      mean2 <- 0

      # mean Group 2
      mean1 <- mean2 + es_true

      for(i in 1:n_studies){

        if(min_obs < max_obs){
          n <- sample(min_obs:max_obs, 1)
        }else if(min_obs == max_obs){
          n <- min_obs
        }else{
          n <- sample(min_obs:max_obs, 1)
        }

        if(random){
          study_mean1 <- rnorm(1, mean = mean1, sd = tau)
          study_mean2 <- rnorm(1, mean = mean2, sd = tau)
        }else if(fixed){
          study_mean1 = mean1
          study_mean2 = mean2
        }

        # different ns for groups
        n1 <- round(rnorm(1,n,n_variance))
        n2 <- round(rnorm(1,n,n_variance))

        if(n1 <= 0){
          stop('n1 <= 0. Please choose smaller variance between groups (`n_variance`)')
        }
        if(n2 <= 0){
          stop('n2 <= 0. Please choose smaller variance between groups (`n_variance`)')
        }

        data_list[[i]] <- tibble('x' = list(rnorm(n1,
                                                     study_mean1,
                                                     1)),
                                     'y' = list(rnorm(n2,
                                                  study_mean2,
                                                  1))) %>%
          mutate(study = i)

      }

      data_raw <- data_list %>%
        bind_rows() %>%
        tibble()

      nam <- c("mean", "mean", "sd", "sd", "n", "n")
      lookup <- paste0(nam, c(1,2))
      new_names <- paste0(nam,"_", varnames)

      if(metaregression){
        new_names <- c(new_names, mod_varname)
        lookup <- c(lookup, 'moderator')
      }

      if(n_variance == 0){
        data_raw <- data_raw %>%
          unnest(c(x, y))

        # if n1 = n2:
        data_aggr <- data_raw %>%
          group_by(study) %>%
          summarise(mean1 = mean(x),
                    mean2 = mean(y),
                    sd1 = sd(x),
                    sd2 = sd(y),
                    n1 = length(x),
                    n2 = length(y))

      }else if(n_variance > 0){
        # if n1 is not n2:
        data_aggr <- data_raw %>%
          group_by(study) %>%
          summarise(mean1 = map(x,mean),
                    mean2 = map(y,mean),
                    sd1 = map(x,sd),
                    sd2 = map(y,sd),
                    n1 = map(x,length),
                    n2 = map(y,length)) %>%
          unnest(cols = all_of(paste0(nam, c(1,2))))
      }

      if(metaregression){
        data_aggr <- data_aggr %>%
          mutate(moderator = sample(mod_labels,nrow(data_aggr), replace = TRUE))

        mod_effects <- c(0, mod_effect)

        for(i in seq_along(mod_labels)){
          data_aggr <- data_aggr %>%
            mutate(mean2 = ifelse(moderator == mod_labels[i], mean2 + mod_effects[i], mean2))
        }
      }

      # if(metaregression & mod_labels == 'continuous'){
      #
      # }

      # data_aggr %>%
      #   group_by(moderator) %>%
      #   mutate(mean_diff = mean1 - mean2) %>%
      #   summarise(mean_diff = mean(mean_diff)) %>%
      #   mutate(diff = lead(mean_diff),
      #          diffdiff = mean_diff - diff)


      data_aggr <- data_aggr %>%
        escalc(data = .,
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
        select(study, hedges_g, se, everything())

  }else if(es == 'ZCOR'){

    for(i in 1:n_studies){
      if(min_obs < max_obs){
        n <- sample(min_obs:max_obs, 1)
      }else if(min_obs == max_obs){
        n <- min_obs
      }else{
        n <- sample(min_obs:max_obs, 1)
      }

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
      bind_rows() %>%
      tibble()

    data_aggr <- data_raw %>%
      group_by(study) %>%
      summarise(r = cor(!!sym(varnames[1]),
                        !!sym(varnames[2])),
                z = fisherz(r),
                n = length(!!sym(varnames[1])),
                se = 1/sqrt(n-3)) %>%
      select(study, z,n,se, everything())

    if(metaregression){
      data_aggr <- data_aggr %>%
        mutate(moderator = sample(mod_labels,nrow(data_aggr), replace = T))

      for(i in seq_along(mod_labels)){
        data_aggr <- data_aggr %>%
          mutate(z = ifelse(moderator == mod_labels[i], z + mod_effects[i], z))
      }
    }

    data_aggr <- data_aggr %>%
      rename(!!!setNames('moderator', mod_varname)) %>%
      mutate(r = fisherz2r(z))

  }else{
    stop("Please specify type of effect size ('ZCOR' or 'SMD').")
  }

    return_list <- list(data_raw = data_raw,
                      data_aggr = data_aggr,
                      es_true = es_true,
                      tau = tau)

    if(aggregate){
      return(data_aggr)
    }else{
      return(return_list)
    }
}
