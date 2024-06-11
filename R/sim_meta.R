#' sim_meta
#'
#' @param min_obs minimum number of observations per study
#' @param max_obs maximum number of observations per study
#' @param n_studies number of studies
#' @param smd_true true effect size of standardized mean difference between variable x and y
#' @param r_true correlation between x and y. Has to be specified if effect size is with-groups (correlation/ pre-post mean difference)
#' @param es type of effect size (choose 'SMD' fpr standardized mean difference and 'ZCOR' for correlations)
#' @param sd1 standard deviation of x
#' @param sd2 standard deviation of y
#' @param random if `TRUE` simulation includes between study heterogenity (random-effects model), if `FALSE` fixed effects model is used
#' @param tau specify standard deviation of between study heterogenity. If moderator variable specified, tau is the residual heterogenity after including the moderator.
#' @param varnames variable names (default: x and y)
#' @param metaregression set TRUE if categorical moderator should be included.
#' @param mod_varname specify the variable name of the moderator
#' @param mod_labels labels of different subgroups of studies, if the moderator is a categorical variable.
#' @param mod_effect standardize size of moderation effect for categorical moderator. Provide a vector of multiple effect sizes if moderator variable includes more than two groups.
#' @param aggregate return only aggregated data (TRUE) or raw data (FALSE).
#'
#' @return list containing raw data (data_raw) and aggregated data with computed effects sizes and standard errors (data_aggr)
#' @export
#' @importFrom psych fisherz fisherz2r
#' @importFrom metafor escalc
#' @importFrom tidyr unnest
#' @importFrom faux rnorm_multi
#' @importFrom dplyr summarise bind_rows group_by %>% mutate sym tibble rename select
#' @importFrom purrr map
#' @importFrom stats cor rnorm sd setNames
#' @examples
#' sim_meta(min_obs = 100, max_obs = 500, n_studies = 20, smd_true = 0.7)

sim_meta <- function(min_obs = 100,
                     max_obs = 500,
                     n_studies = 100,
                     smd_true = 0.5,
                     r_true = 0,
                     es = 'SMD',
                     sd1 = 1,
                     sd2 = 1,
                     random = FALSE,
                     tau = 0.01,
                     varnames = c('x','y'),
                     metaregression = FALSE,
                     mod_varname = c(),
                     mod_labels = c(),
                     mod_effect = NA,
                     aggregate = TRUE
                     ){

  ## errors, warnings, messages ##
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
  }

  if(min_obs > max_obs){
    warning('Minimum number of observations is lower than maximum. Please adjust `min_obs` and `max_obs`.')
  }

  # if(fixed & random){
  #   message('Both fixed and random were chosen. Only random-effects model is applied.')
  # }

  # if(es == 'ZCOR'){
  #   message('n_variance is ignored because of within sample effect size.')
  # }

  ### DATA SIMULATION ###
  data_list <- list()

  for(i in 1:n_studies){

    if(min_obs < max_obs){
      n <- sample(min_obs:max_obs, 1)
    }else if(min_obs == max_obs){
      n <- min_obs
    }else{
      n <- sample(min_obs:max_obs, 1)
    }

    n_variance <- 0
    # different ns for groups
    n1 <- round(rnorm(1,n,n_variance))
    n2 <- round(rnorm(1,n,n_variance))

    s_pooled <- sqrt((((n1-1)*sd1^2) + ((n2-1)*sd2^2))/((n1-1)+(n2-1)))

    # mean Group 1
    mean1 <- 0

    # mean Group 2
    mean2 <- mean1 + smd_true*s_pooled

    if(random & es == 'SMD'){
      study_mean1 <- rnorm(1, mean = mean1, sd = tau)
      study_mean2 <- rnorm(1, mean = mean2, sd = tau)
      r_study <- r_true
    }else if(random & es == 'ZCOR'){
        r_study <- fisherz2r(rnorm(1, mean = r_true, sd = tau))
        study_mean1 <- mean1
        study_mean2 <- mean2
    }else{
      study_mean1 <- mean1
      study_mean2 <- mean2
      r_study <- r_true
    }

    if(n1 <= 0){
      stop('n1 <= 0. Please choose smaller variance between groups (`n_variance`)')
    }
    if(n2 <= 0){
      stop('n2 <= 0. Please choose smaller variance between groups (`n_variance`)')
    }

    # data_list[[i]] <- tibble('x' = list(rnorm(n1,
    #                                              study_mean1,
    #                                              1)),
    #                              'y' = list(rnorm(n2,
    #                                           study_mean2,
    #                                           1))) %>%
    #   mutate(study = i)

    # corr = 1/-1 will lead to collaps in rnorm_multi
    if(r_study == 1){
      r_study <- .99
    }else if(r_study == -1){
      r_study <- .99
    }

    data_list[[i]] <- data.frame(rnorm_multi(n = n,
                                             vars = 2,
                                             mu = c(study_mean1, study_mean2),
                                             sd = c(sd1, sd2),
                                             r = r_study,
                                             varnames = c('x', 'y'))) %>%
      mutate(study = i)

    }

    data_raw <- data_list %>%
      bind_rows() %>%
      tibble()


    ### CALCULATING EFFECT SIZES ###

    if(es == 'SMD'){

      ### names of old and new variables ###

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

    ### INCLUDE MODERATOR ###

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

    nam <- c("mean", "mean", "sd", "sd", "n", "n")
    lookup <- paste0(nam, c(1,2))
    new_names <- paste0(nam,"_", varnames)

    if(metaregression){
      new_names <- c(new_names, mod_varname)
      lookup <- c(lookup, 'moderator')
    }

    data_aggr <- data_aggr %>%
      escalc(data = .,
                     measure = 'SMD',
                     m1i = mean2,
                     m2i = mean1,
                     sd1i = sd2,
                     sd2i = sd1,
                     n1i = n2,
                     n2i = n1) %>%
      mutate(se = sqrt(vi)) %>%
      rename(!!!setNames(lookup, new_names)) %>%
      rename(hedges_g = yi) %>%
      tibble() %>%
      select(study, hedges_g, se, everything())

    ### CORRELATIONS ###
    }else if(es == 'ZCOR'){

      data_aggr <- data_raw %>%
        group_by(study) %>%
        summarise(r = cor(x,y),
                  z = fisherz(r),
                  n = length(x),
                  se = 1/sqrt(n-3))

      if(metaregression){
        data_aggr <- data_aggr %>%
          mutate(moderator = sample(mod_labels,nrow(data_aggr), replace = T))

      mod_effects <- c(0, mod_effect)

      for(i in seq_along(mod_labels)){
          data_aggr <- data_aggr %>%
            mutate(z = ifelse(moderator == mod_labels[i], z + mod_effects[i], z))
      }

      data_aggr <- data_aggr %>%
        rename(!!!setNames('moderator', mod_varname))
      }

      data_aggr <- data_aggr %>%
        mutate(r = fisherz2r(z)) %>%
        select(study, z, r,n,se, everything())
    }

    if(aggregate){
      return(data_aggr)
    }else{
      return(data_raw)
    }
}
