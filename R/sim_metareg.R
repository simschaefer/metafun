#' sim_metareg
#'
#' @param min_obs minimum number of observations per study
#' @param max_obs maximum number of observations per study
#' @param n_studies number of studies
#' @param intercept effect size (Hedges' g) without moderation effect
#' @param random choose TRUE to add variability of true effect size
#' @param tau standard deviation of true effect size
#' @param formula specify metaregression formula
#' @param mod_types types of predictor variables (categorical = 'cat', continuous = 'cont')
#'
#' @return data frame containing aggregated data
#' @export
#' @importFrom metafor escalc
#' @importFrom stringr str_replace_all
#' @importFrom dplyr rename
#' @importFrom stats cor rnorm sd setNames rbinom
#' @examples
#' sim <- sim_metareg(random = TRUE,
#' tau = 0.05,
#' formula = y ~ -0.5*x1 + 1.2*x2,
#' mod_types = c('cat', 'cont'))

sim_metareg <- function(min_obs = 100,
                     max_obs = 500,
                     n_studies = 100,
                     intercept = 0.5,
                     random = FALSE,
                     tau = 0.01,
                     formula,
                     mod_types){

  if(min_obs > max_obs){
    warning('Minimum number of observations is lower than maximum. Please adjust `min_obs` and `max_obs`.')
  }

  ### MODERATION EFFECTS ###

  # Extract the formula components
  formula_parts <- as.character(formula)
  response_var <- formula_parts[2]

  # Extract predictors and coefficients
  terms <- strsplit(formula_parts[3], " + ", fixed = TRUE)[[1]]
  predictors <- sapply(strsplit(terms, "*", fixed = TRUE), function(x) x[2])
  coefficients <- as.numeric(sapply(strsplit(terms, "*", fixed = TRUE), function(x) x[1]))

  if(random){
    A <- data.frame(intercept = rnorm(n_studies, mean = intercept, sd = tau))
  }else{
    A <- data.frame(intercept = rep(intercept, n_studies))
  }


  #coefficients vector
  beta <- coefficients

  for(i in seq_along(predictors)){
    A[predictors[i]] <- if(mod_types[i] == 'cat'){
      rbinom(n_studies, 1, prob = 0.5)
    }else if(mod_types[i] == 'cont'){
        rnorm(n_studies)
      }
  }

  A['hedges_g'] <- A['intercept'] + as.matrix(A[predictors]) %*% beta

  A_df <- as.data.frame(A)

  if(min_obs < max_obs){
    n <- sample(min_obs:max_obs, n_studies, replace = TRUE)
  }else if(min_obs == max_obs){
    n <- rep(min_obs, n_studies)
  }else{
    n <- sample(min_obs:max_obs, n_studies, replace = TRUE)
  }

  A_df$n <- n

  for(i in 1:nrow(A_df)){

    random <- rnorm(A_df$n[i], mean = A_df$hedges_g[i])
    sd <- sd(random)
    m <- mean(random)

    A_df$m[i] <- m
    A_df$se[i] <- sd/sqrt(A_df$n[i])

  }

  A_df <- escalc(data = A_df,
         yi = m,
         ni = n,
         sei = se,
         measure = 'SMD')

  new_names <- str_replace_all(predictors, " ", "")
  old_names <- paste0('X.', new_names)

  A_df <- A_df %>%
    rename(!!!setNames(old_names, new_names)) %>%
    select(hedges_g, n, se, intercept, everything())


  return(A_df)

}

