#' estimate_dfa_alpha
#'
#' Estimate the DFA (Detrended Fluctuation Analysis) alpha exponent of a time series.
#'
#' @param y A numeric vector (the time series)
#' @param min_window Minimum window size (default = 4)
#' @param max_window Maximum window size (default = length(y)/4)
#' @param step Number of window sizes to evaluate (log-spaced)
#' @return A list with estimated alpha and regression summary
#' @export

estimate_dfa_alpha <- function(y, min_window = 4, max_window = NULL, step = 20) {
  if (!is.numeric(y)) stop("Input y must be a numeric vector.")
  y <- as.numeric(y)
  N <- length(y)
  if (is.null(max_window)) max_window <- floor(N / 4)

  # Step 1: Integration (cumulative sum minus mean)
  y_mean <- mean(y)
  y_int <- cumsum(y - y_mean)

  # Step 2: Define scales (window sizes)
  scales <- floor(exp(seq(log(min_window), log(max_window), length.out = step)))

  fluctuations <- numeric(length(scales))

  for (i in seq_along(scales)) {
    win <- scales[i]
    n_win <- floor(N / win)
    rms <- numeric(n_win)

    for (j in 1:n_win) {
      idx <- ((j - 1) * win + 1):(j * win)
      segment <- y_int[idx]
      fit <- lm(segment ~ seq_along(segment))
      detrended <- residuals(fit)
      rms[j] <- sqrt(mean(detrended^2))
    }

    fluctuations[i] <- sqrt(mean(rms^2))
  }

  # Step 3: Estimate slope (alpha)
  log_scales <- log(scales)
  log_fluct <- log(fluctuations)

  fit <- lm(log_fluct ~ log_scales)
  alpha <- coef(fit)[2]

  return(list(alpha = alpha, scales = scales, fluct = fluctuations, model = fit))
}
