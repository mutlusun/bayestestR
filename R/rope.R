#' Region of Practical Equivalence (ROPE)
#'
#' Compute the proportion of the HDI (default to the 89\% HDI) of a posterior distribution that lies within a region of practical equivalence.
#'
#' @param x Vector representing a posterior distribution. Can also be a \code{stanreg} or \code{brmsfit} model.
#' @param range ROPE's lower and higher bounds. Should be \code{"default"} or
#' depending on the number of outcome variables a vector or a list. In models with one response,
#' `range` should be a vector of length two (e.g., \code{c(-0.1, 0.1)}). In
#' multivariate models, `range` should be a list with a numeric vectors for
#' each response variable. Vector names should correspond to the name of the response
#' variables. If \code{"default"} and input is a vector, the range is set to \code{c(-0.1,
#' 0.1)}. If \code{"default"} and input is a Bayesian model,
#' \code{\link[=rope_range]{rope_range()}} is used.
#' @param ci The Credible Interval (CI) probability, corresponding to the proportion of HDI, to use for the percentage in ROPE.
#' @param ci_method The type of interval to use to quantify the percentage in ROPE. Can be 'HDI' (default) or 'ETI'. See \code{\link{ci}}.
#'
#' @inheritParams hdi
#'
#' @details
#' \subsection{ROPE}{
#'   Statistically, the probability of a posterior distribution of being
#'   different from 0 does not make much sense (the probability of a single value
#'   null hypothesis in a continuous distribution is 0). Therefore, the idea
#'   underlining ROPE is to let the user define an area around the null value
#'   enclosing values that are \emph{equivalent to the null} value for practical
#'   purposes (\cite{Kruschke 2010, 2011, 2014}).
#'   \cr \cr
#'   Kruschke (2018) suggests that such null value could be set, by default,
#'   to the -0.1 to 0.1 range of a standardized parameter (negligible effect
#'   size according to Cohen, 1988). This could be generalized: For instance,
#'   for linear models, the ROPE could be set as \code{0 +/- .1 * sd(y)}.
#'   This ROPE range can be automatically computed for models using the
#'   \link{rope_range} function.
#'   \cr \cr
#'   Kruschke (2010, 2011, 2014) suggests using the proportion of  the 95\%
#'   (or 89\%, considered more stable) \link[=hdi]{HDI} that falls within the
#'   ROPE as an index for "null-hypothesis" testing (as understood under the
#'   Bayesian framework, see \code{\link[=equivalence_test]{equivalence_test()}}).
#' }
#' \subsection{Sensitivity to parameter's scale}{
#'   It is important to consider the unit (i.e., the scale) of the predictors
#'   when using an index based on the ROPE, as the correct interpretation of the
#'   ROPE as representing a region of practical equivalence to zero is dependent
#'   on the scale of the predictors. Indeed, the percentage in ROPE depend on
#'   the unit of its parameter. In other words, as the ROPE represents a fixed
#'   portion of the response's scale, its proximity with a coefficient depends
#'   on the scale of the coefficient itself.
#' }
#' \subsection{Multicollinearity: Non-independent covariates}{
#'   When parameters show strong correlations, i.e. when covariates are not
#'   independent, the joint parameter distributions may shift towards or
#'   away from the ROPE. Collinearity invalidates ROPE and hypothesis
#'   testing based on univariate marginals, as the probabilities are conditional
#'   on independence. Most problematic are parameters that only have partial
#'   overlap with the ROPE region. In case of collinearity, the (joint) distributions
#'   of these parameters may either get an increased or decreased ROPE, which
#'   means that inferences based on \code{rope()} are inappropriate
#'   (\cite{Kruschke 2014, 340f}).
#'   \cr \cr
#'   \code{rope()} performs a simple check for pairwise correlations between
#'   parameters, but as there can be collinearity between more than two variables,
#'   a first step to check the assumptions of this hypothesis testing is to look
#'   at different pair plots. An even more sophisticated check is the projection
#'   predictive variable selection (\cite{Piironen and Vehtari 2017}).
#' }
#' \subsection{Strengths and Limitations}{
#'   \strong{Strengths:} Provides information related to the practical relevance of the effects.
#'   \cr \cr
#'   \strong{Limitations:} A ROPE range needs to be arbitrarily defined. Sensitive to the scale (the unit) of the predictors. Not sensitive to highly significant effects.
#' }
#'
#' @note There is also a \href{https://easystats.github.io/see/articles/bayestestR.html}{\code{plot()}-method} implemented in the \href{https://easystats.github.io/see/}{\pkg{see}-package}.
#'
#' @references \itemize{
#' \item Cohen, J. (1988). Statistical power analysis for the behavioural sciences.
#' \item Kruschke, J. K. (2010). What to believe: Bayesian methods for data analysis. Trends in cognitive sciences, 14(7), 293-300. \doi{10.1016/j.tics.2010.05.001}.
#' \item Kruschke, J. K. (2011). Bayesian assessment of null values via parameter estimation and model comparison. Perspectives on Psychological Science, 6(3), 299-312. \doi{10.1177/1745691611406925}.
#' \item Kruschke, J. K. (2014). Doing Bayesian data analysis: A tutorial with R, JAGS, and Stan. Academic Press. \doi{10.1177/2515245918771304}.
#' \item Kruschke, J. K. (2018). Rejecting or accepting parameter values in Bayesian estimation. Advances in Methods and Practices in Psychological Science, 1(2), 270-280. \doi{10.1177/2515245918771304}.
#' \item Makowski D, Ben-Shachar MS, Chen SHA, Lüdecke D (2019) Indices of Effect Existence and Significance in the Bayesian Framework. Frontiers in Psychology 2019;10:2767. \doi{10.3389/fpsyg.2019.02767}
#' \item Piironen, J., & Vehtari, A. (2017). Comparison of Bayesian predictive methods for model selection. Statistics and Computing, 27(3), 711–735. \doi{10.1007/s11222-016-9649-y}
#' }
#'
#' @examples
#' library(bayestestR)
#'
#' rope(x = rnorm(1000, 0, 0.01), range = c(-0.1, 0.1))
#' rope(x = rnorm(1000, 0, 1), range = c(-0.1, 0.1))
#' rope(x = rnorm(1000, 1, 0.01), range = c(-0.1, 0.1))
#' rope(x = rnorm(1000, 1, 1), ci = c(.90, .95))
#' \dontrun{
#' library(rstanarm)
#' model <- stan_glm(mpg ~ wt + gear, data = mtcars, chains = 2, iter = 200, refresh = 0)
#' rope(model)
#' rope(model, ci = c(.90, .95))
#'
#' library(emmeans)
#' rope(emtrends(model, ~1, "wt"), ci = c(.90, .95))
#'
#' library(brms)
#' model <- brms::brm(mpg ~ wt + cyl, data = mtcars)
#' rope(model)
#' rope(model, ci = c(.90, .95))
#'
#' library(brms)
#' model <- brms::brm(brms::mvbind(mpg, disp) ~ wt + cyl, data = mtcars)
#' rope(model)
#' rope(model, ci = c(.90, .95))
#'
#' library(BayesFactor)
#' bf <- ttestBF(x = rnorm(100, 1, 1))
#' rope(bf)
#' rope(bf, ci = c(.90, .95))
#' }
#' @importFrom insight get_parameters is_multivariate
#' @export
rope <- function(x, ...) {
  UseMethod("rope")
}


#' @method as.double rope
#' @export
as.double.rope <- function(x, ...) {
  x$ROPE_Percentage
}



#' @rdname rope
#' @export
rope.default <- function(x, ...) {
  NULL
}



#' @rdname rope
#' @export
rope.numeric <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  if (all(range == "default")) {
    range <- c(-0.1, 0.1)
  } else if (!all(is.numeric(range)) || length(range) != 2) {
    stop("`range` should be 'default' or a vector of 2 numeric values (e.g., c(-0.1, 0.1)).")
  }

  rope_values <- lapply(ci, function(i) {
    .rope(x, range = range, ci = i, ci_method = ci_method, verbose = verbose)
  })

  # "do.call(rbind)" does not bind attribute values together
  # so we need to capture the information about HDI separately


  out <- do.call(rbind, rope_values)
  if (nrow(out) > 1) {
    out$ROPE_Percentage <- as.numeric(out$ROPE_Percentage)
  }

  # Attributes
  hdi_area <- cbind(CI = ci * 100, data.frame(do.call(rbind, lapply(rope_values, attr, "HDI_area"))))
  names(hdi_area) <- c("CI", "CI_low", "CI_high")

  attr(out, "HDI_area") <- hdi_area
  attr(out, "data") <- x

  class(out) <- unique(c("rope", "see_rope", class(out)))

  out
}




#' @rdname rope
#' @export
rope.data.frame <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  out <- .prepare_rope_df(x, range, ci, ci_method, verbose)
  HDI_area_attributes <- .compact_list(out$HDI_area)
  dat <- data.frame(
    Parameter = rep(names(HDI_area_attributes), each = length(ci)),
    out$tmp,
    stringsAsFactors = FALSE
  )
  row.names(dat) <- NULL

  attr(dat, "HDI_area") <- HDI_area_attributes
  attr(dat, "object_name") <- .safe_deparse(substitute(x))

  class(dat) <- c("rope", "see_rope", "data.frame")
  dat
}



#' @rdname rope
#' @export
rope.emmGrid <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  xdf <- insight::get_parameters(x)

  dat <- rope(xdf, range = range, ci = ci, ci_method = ci_method, verbose = verbose, ...)
  attr(dat, "object_name") <- .safe_deparse(substitute(x))
  dat
}

#' @export
rope.emm_list <- rope.emmGrid



#' @rdname rope
#' @export
rope.BFBayesFactor <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  if (all(range == "default")) {
    range <- rope_range(x)
  }
  out <- rope(insight::get_parameters(x), range = range, ci = ci, ci_method = ci_method, verbose = verbose, ...)
  attr(out, "object_name") <- .safe_deparse(substitute(x))
  out
}


#' @export
rope.bamlss <- rope.BFBayesFactor


#' @rdname rope
#' @export
rope.MCMCglmm <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  nF <- x$Fixed$nfl
  out <- rope(as.data.frame(x$Sol[, 1:nF, drop = FALSE]), range = range, ci = ci, ci_method = ci_method, verbose = verbose, ...)
  attr(out, "object_name") <- .safe_deparse(substitute(x))
  out
}


#' @export
rope.mcmc <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  out <- rope(as.data.frame(x), range = range, ci = ci, ci_method = ci_method, verbose = verbose, ...)
  attr(out, "object_name") <- NULL
  attr(out, "data") <- .safe_deparse(substitute(x))
  out
}




#' @export
rope.bcplm <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  out <- rope(insight::get_parameters(x), range = range, ci = ci, ci_method = ci_method, verbose = verbose, ...)
  attr(out, "object_name") <- NULL
  attr(out, "data") <- .safe_deparse(substitute(x))
  out
}




#' @export
rope.bayesQR <- function(x, range = "default", ci = .89, ci_method = "HDI", verbose = TRUE, ...) {
  out <- rope(insight::get_parameters(x), range = range, ci = ci, ci_method = ci_method, verbose = verbose, ...)
  attr(out, "object_name") <- NULL
  attr(out, "data") <- .safe_deparse(substitute(x))
  out
}


#' @export
rope.mcmc.list <- rope.bayesQR



#' @keywords internal
.rope <- function(x, range = c(-0.1, 0.1), ci = .89, ci_method = "HDI", verbose = TRUE) {
  ci_bounds <- ci(x, ci = ci, method = ci_method, verbose = verbose)

  if (anyNA(ci_bounds)) {
    rope_percentage <- NA
  } else {
    HDI_area <- x[x >= ci_bounds$CI_low & x <= ci_bounds$CI_high]
    area_within <- HDI_area[HDI_area >= min(range) & HDI_area <= max(range)]
    rope_percentage <- length(area_within) / length(HDI_area)
  }


  rope <- data.frame(
    "CI" = ci * 100,
    "ROPE_low" = range[1],
    "ROPE_high" = range[2],
    "ROPE_Percentage" = rope_percentage
  )

  attr(rope, "HDI_area") <- c(ci_bounds$CI_low, ci_bounds$CI_high)
  attr(rope, "CI_bounds") <- c(ci_bounds$CI_low, ci_bounds$CI_high)
  class(rope) <- unique(c("rope", "see_rope", class(rope)))
  rope
}



#' @rdname rope
#' @export
rope.stanreg <- function(x, range = "default", ci = .89, ci_method = "HDI", effects = c("fixed", "random", "all"), component = c("location", "all", "conditional", "smooth_terms", "sigma", "distributional", "auxiliary"), parameters = NULL, verbose = TRUE, ...) {
  effects <- match.arg(effects)
  component <- match.arg(component)

  if (all(range == "default")) {
    range <- rope_range(x)
  } else if (!all(is.numeric(range)) || length(range) != 2) {
    stop("`range` should be 'default' or a vector of 2 numeric values (e.g., c(-0.1, 0.1)).")
  }

  # check for possible collinearity that might bias ROPE
  if (verbose) .check_multicollinearity(x, "rope")

  rope_data <- rope(
    insight::get_parameters(x, effects = effects, component = component, parameters = parameters),
    range = range,
    ci = ci,
    ci_method = ci_method,
    verbose = verbose,
    ...
  )

  out <- .prepare_output(rope_data, insight::clean_parameters(x), inherits(x, "stanmvreg"))

  attr(out, "HDI_area") <- attr(rope_data, "HDI_area")
  attr(out, "object_name") <- .safe_deparse(substitute(x))
  class(out) <- class(rope_data)

  out
}

#' @export
rope.stanfit <- rope.stanreg


#' @rdname rope
#' @export
rope.brmsfit <- function(
  x, 
  range = "default", 
  ci = .89, 
  ci_method = "HDI", 
  effects = c("fixed", "random", "all"), 
  component = c("conditional", "zi", "zero_inflated", "all"), 
  parameters = NULL, 
  verbose = TRUE, 
  ...
) {
  effects <- match.arg(effects)
  component <- match.arg(component)

  # check range argument
  if (all(range == "default")) {
    range <- rope_range(x)
  # we expect a list with named vectors (length two) in the multivariate case.
  # Names state the response variable.
  } else if (insight::is_multivariate(x) && 
    (!is.list(range) || length(range) != length(insight::find_response(x)) ||
        names(range) != insight::find_response(x))) {
    stop("With a multivariate model, `range` should be 'default' or a list of named numeric vectors with length 2.")
  } else if (!all(is.numeric(range)) || length(range) != 2) {
    stop("`range` should be 'default' or a vector of 2 numeric values (e.g., c(-0.1, 0.1)).")
  }

  # check for possible collinearity that might bias ROPE and print a warning
  if (verbose) .check_multicollinearity(x, "rope")

  # calc rope
  if (insight::is_multivariate(x)) {
    dv <- insight::find_response(x)

    # ROPE range / width differs between response varialbe. Thus ROPE is
    # calculated for every variable on its own.
    rope_data <- lapply(
      dv,
      function(dv_item) {
        ret <- rope(
          insight::get_parameters(x, effects = effects, component = component, parameters = parameters),
          range = range[[dv_item]],
          ci = ci,
          ci_method = ci_method,
          verbose = verbose,
          ...
        )

        # It's a waste of performance to calculate ROPE for all parameters
        # with the ROPE width of a specific response variable and to throw
        # away the unwanted results. However, performance impact should not be
        # too high and this way it is much easier to handle the `parameters`
        # argument.
        ret[grepl(paste0("(.*)", dv_item), ret$Parameter), ]
      }
    )
    rope_data <- do.call(rbind, rope_data)

    out <- .prepare_output(rope_data, insight::clean_parameters(x), is_brms_mv = TRUE)
  } else {
    rope_data <- rope(
      insight::get_parameters(x, effects = effects, component = component, parameters = parameters),
      range = range,
      ci = ci,
      ci_method = ci_method,
      verbose = verbose,
      ...
    )

    out <- .prepare_output(rope_data, insight::clean_parameters(x))
  }

  attr(out, "HDI_area") <- attr(rope_data, "HDI_area")
  attr(out, "object_name") <- .safe_deparse(substitute(x))
  class(out) <- class(rope_data)

  out
}



#' @export
rope.sim.merMod <- function(x, range = "default", ci = .89, ci_method = "HDI", effects = c("fixed", "random", "all"), parameters = NULL, verbose = TRUE, ...) {
  effects <- match.arg(effects)

  if (all(range == "default")) {
    range <- rope_range(x)
  } else if (!all(is.numeric(range)) || length(range) != 2) {
    stop("`range` should be 'default' or a vector of 2 numeric values (e.g., c(-0.1, 0.1)).")
  }

  list <- lapply(c("fixed", "random"), function(.x) {
    parms <- insight::get_parameters(x, effects = .x, parameters = parameters)

    getropedata <- .prepare_rope_df(parms, range, ci, ci_method, verbose)
    tmp <- getropedata$tmp
    HDI_area <- getropedata$HDI_area

    if (!.is_empty_object(tmp)) {
      tmp <- .clean_up_tmp_stanreg(
        tmp,
        group = .x,
        cols = c("CI", "ROPE_low", "ROPE_high", "ROPE_Percentage", "Group"),
        parms = names(parms)
      )

      if (!.is_empty_object(HDI_area)) {
        attr(tmp, "HDI_area") <- HDI_area
      }
    } else {
      tmp <- NULL
    }

    tmp
  })

  dat <- do.call(rbind, args = c(.compact_list(list), make.row.names = FALSE))

  dat <- switch(
    effects,
    fixed = .select_rows(dat, "Group", "fixed"),
    random = .select_rows(dat, "Group", "random"),
    dat
  )

  if (all(dat$Group == dat$Group[1])) {
    dat <- .remove_column(dat, "Group")
  }

  HDI_area_attributes <- lapply(.compact_list(list), attr, "HDI_area")

  if (effects != "all") {
    HDI_area_attributes <- HDI_area_attributes[[1]]
  } else {
    names(HDI_area_attributes) <- c("fixed", "random")
  }

  attr(dat, "HDI_area") <- HDI_area_attributes
  attr(dat, "object_name") <- .safe_deparse(substitute(x))

  dat
}



#' @export
rope.sim <- function(x, range = "default", ci = .89, ci_method = "HDI", parameters = NULL, verbose = TRUE, ...) {
  if (all(range == "default")) {
    range <- rope_range(x)
  } else if (!all(is.numeric(range)) || length(range) != 2) {
    stop("`range` should be 'default' or a vector of 2 numeric values (e.g., c(-0.1, 0.1)).")
  }

  parms <- insight::get_parameters(x, parameters = parameters)
  getropedata <- .prepare_rope_df(parms, range, ci, ci_method, verbose)

  dat <- getropedata$tmp
  HDI_area <- getropedata$HDI_area

  if (!.is_empty_object(dat)) {
    dat <- .clean_up_tmp_stanreg(
      dat,
      group = "fixed",
      cols = c("CI", "ROPE_low", "ROPE_high", "ROPE_Percentage"),
      parms = names(parms)
    )

    if (!.is_empty_object(HDI_area)) {
      attr(dat, "HDI_area") <- HDI_area
    }
  } else {
    dat <- NULL
  }

  attr(dat, "object_name") <- .safe_deparse(substitute(x))

  dat
}




#' @keywords internal
.prepare_rope_df <- function(parms, range, ci, ci_method, verbose) {
  tmp <- sapply(
    parms,
    rope,
    range = range,
    ci = ci,
    ci_method = ci_method,
    verbose = verbose,
    simplify = FALSE
  )

  HDI_area <- lapply(tmp, function(.x) {
    attr(.x, "HDI_area")
  })

  # HDI_area <- lapply(HDI_area, function(.x) {
  #   dat <- cbind(CI = ci, data.frame(do.call(rbind, .x)))
  #   colnames(dat) <- c("CI", "HDI_low", "HDI_high")
  #   dat
  # })

  list(
    tmp = do.call(rbind, tmp),
    HDI_area = HDI_area
  )
}
