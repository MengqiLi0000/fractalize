#' auto_fractalize
#'
#' Automatically modify a time series to reach a target DFA alpha exponent.
#'
#' @param y A numeric vector (original time series)
#' @param target_alpha Desired fractal alpha value (default = 1)
#' @param max_iter Maximum number of iterations
#' @param tolerance Acceptable deviation from target alpha
#' @param verbose Print alpha values during adjustment
#' @param seed Optional random seed
#' @return A list with transformed series and estimated alpha
#' @export

auto_fractalize <- function(y, target_alpha = 1, max_iter = 20, tolerance = 0.05, verbose = TRUE, seed = NULL) {
  if (!is.numeric(y)) stop("Input must be a numeric vector.")
  if (!requireNamespace("stats", quietly = TRUE)) stop("stats package required.")

  y_current <- y
  if (!is.null(seed)) set.seed(seed)

  for (i in 1:max_iter) {
    dfa_result <- estimate_dfa_alpha(y_current)
    alpha <- dfa_result$alpha

    if (verbose) {
      cat(sprintf("Iteration %d: alpha = %.4f\n", i, alpha))
    }

    if (abs(alpha - target_alpha) < tolerance) {
      break
    }

    # Adjust power spectrum to approach target alpha
    # Basic idea: shift toward 1/f^alpha target in frequency domain
    y_fft <- fft(y_current)
    n <- length(y_current)
    freq <- 1:(n %/% 2)
    filter <- 1 / (freq ^ (target_alpha / 2))
    full_filter <- c(1, filter, rev(filter[1:(n - length(filter) - 1)]))

    y_fft <- y_fft * full_filter
    y_new <- Re(fft(y_fft, inverse = TRUE)) / n
    y_current <- scale(y_new)  # standardize
  }

  return(list(fractal_y = as.numeric(y_current), alpha = alpha, iter = i))
}
