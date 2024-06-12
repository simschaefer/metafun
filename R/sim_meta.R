#' sim_meta
#'
#' @param min_obs minimum number of observations per study
#' @param max_obs maximum number of observations per study
#' @param n_studies number of studies
#' @param smd_true true effect size of standardized mean difference between variable x and y
#' @param r_true correlation between x and y. Has to be specified if effect size is with-groups (correlation/ pre-post mean difference)
#' @param sd1 standard deviation of x
#' @param sd2 standard deviation of y
#' @param random if `TRUE` simulation includes between study heterogenity (random-effects model), if `FALSE` fixed effects model is used
#' @param tau specify standard deviation of between study heterogenity. If moderator variable specified, tau is the residual heterogenity after including the moderator.
#' @param metaregression set TRUE if categorical moderator should be included.
#' @param mod_name variable name of moderator variable
#' @param mod_labels labels of different subgroups of studies, if the moderator is a categorical variable.
#' @param smd_mod_effects effect sizes in subgroups. Provide a vector of multiple effect sizes if moderator variable includes more than one group.
#' @param r_mod_effects effect on correlation in each subgroup.
#' @param aggregate return only aggregated data (TRUE) or raw data (FALSE).
#' @param random_effects Choose if 'SMD' or 'ZCOR' should be include random effects
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
                     sd1 = 1,
                     sd2 = 1,
                     random = FALSE,
                     tau = 0.01,
                     metaregression = FALSE,
                     mod_name = 'subgroups',
                     mod_labels = c(),
                     smd_mod_effects = c(),
                     r_mod_effects = c(),
                     aggregate = TRUE,
                     random_effects = c()
                     ){

  ## errors, warnings, messages ##
  if(!metaregression){
    smd_mod_effects <- 0
    mod_name <- 'subgroups'
  }else{
    if(length(mod_labels)!= length(smd_mod_effects)){
      n_effects <- length(smd_mod_effects)
      n_labels <- length(mod_labels)
      warning(paste0('Number of moderator labels (',n_labels,') does not match the number of effect sizes (',n_effects,'). Only the first ',n_labels-1,' effect sizes are used.'))
    }
  }

  # if(length(varnames) > 2){
  #   warning(paste0('Number of variable names is too large (',length(varnames),'). Only the first two names are used.'))
  #   varnames <- varnames[1:2]
  # }else if(length(varnames) == 1){
  #   warning("You only specified one variable name. The second variable is called 'y'.")
  #   varnames <- c(varnames, 'y')
  # }

  if(min_obs > max_obs){
    warning('Minimum number of observations is lower than maximum. Please adjust `min_obs` and `max_obs`.')
  }

  # if(fixed & random){
  #   message('Both fixed and random were chosen. Only random-effects model is applied.')
  # }

  # if(es == 'ZCOR'){
  #   message('n_variance is ignored because of within sample effect size.')
  # }

  ### MODERATION EFFECTS ###

  if(metaregression){
  mod_data <- tibble(smd_mod_effects = smd_mod_effects,
                     r_mod_effects = r_mod_effects,
         subgroups = mod_labels,
         r_true = r_true,
         smd_true = smd_true)
    }
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

    if(metaregression){
      subgroup <- sample(1:length(mod_labels), 1)
      smd_mod_eff <- smd_mod_effects[subgroup]
      r_mod_eff <- r_mod_effects[subgroup]
    }else{
      smd_mod_eff <- 0
      r_mod_eff <- 0
    }

    # mean Group 2
    mean2 <- mean1 + smd_true*s_pooled + smd_mod_eff*s_pooled

    r <- r_true + r_mod_eff

    if(random & 'SMD' %in% random_effects){
      study_mean1 <- rnorm(1, mean = mean1, sd = tau)
      study_mean2 <- rnorm(1, mean = mean2, sd = tau)
      r_study <- r
    }else if(random & 'ZCOR' %in% random_effects){
        r_study <- fisherz2r(rnorm(1, mean = r, sd = tau))
        study_mean1 <- mean1
        study_mean2 <- mean2
    }else{
      study_mean1 <- mean1
      study_mean2 <- mean2
      r_study <- r
    }

    if(n1 <= 0){
      stop('n1 <= 0. Please choose smaller variance between groups (`n_variance`)')
    }
    if(n2 <= 0){
      stop('n2 <= 0. Please choose smaller variance between groups (`n_variance`)')
    }

    # corr = 1/-1 will lead to collaps in rnorm_multi
    if(r_study >= 1){
      r_study <- .99
    }else if(r_study <= -1){
      r_study <- .99
    }

    data_list[[i]] <- data.frame(rnorm_multi(n = n,
                                             vars = 2,
                                             mu = c(study_mean1, study_mean2),
                                             sd = c(sd1, sd2),
                                             r = r_study,
                                             varnames = c('x', 'y'))) %>%
      mutate(study = i)

    if(metaregression){
      data_list[[i]] <- data_list[[i]] %>%
        mutate(subgroups = mod_labels[subgroup])
    }else{
      data_list[[i]] <- data_list[[i]] %>%
        mutate(subgroups = NA)
    }

    }

    data_raw <- data_list %>%
      bind_rows() %>%
      tibble()

      data_raw <- data_raw %>%
        unnest(c(x, y))

      # if n1 = n2:
      data_aggr <- data_raw %>%
        group_by(study, subgroups) %>%
        summarise(mean1 = mean(x),
                  mean2 = mean(y),
                  sd1 = sd(x),
                  sd2 = sd(y),
                  n1 = length(x),
                  n2 = length(y),
                  r = cor(x,y),
                  z = fisherz(r),
                  n = length(x),
                  se_z = 1/sqrt(n-3))

      if(metaregression){
        data_aggr <- data_aggr %>%
          left_join(mod_data, by = join_by('subgroups')) %>%
          rename(!!!setNames('subgroups', mod_name))
      }else{
        data_aggr <- data_aggr %>%
          select(-subgroups)
      }

    # nam <- c("mean", "mean", "sd", "sd", "n", "n")
    # lookup <- paste0(nam, c(1,2))
    # new_names <- paste0(nam,"_", varnames)

    # if(metaregression){
    #   new_names <- c(new_names, mod_varname)
    #   lookup <- c(lookup, 'subgroups')
    # }

    data_aggr <- data_aggr %>%
      escalc(data = .,
                     measure = 'SMD',
                     m1i = mean2,
                     m2i = mean1,
                     sd1i = sd2,
                     sd2i = sd1,
                     n1i = n2,
                     n2i = n1) %>%
      mutate(se_g = sqrt(vi)) %>%
      # rename(!!!setNames(lookup, new_names)) %>%
      rename(hedges_g = yi,
             variance_g = vi) %>%
      tibble() %>%
      select(study, hedges_g,z,r, se_g, se_z, everything())


    if(aggregate){
      return(data_aggr)
    }else{
      return(data_raw)
    }
}

