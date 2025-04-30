#' fractalize_series
#'
#' Transform a univariate time series into a fractal-like series by applying pink-noise smoothing.
#'
#' @param data A data.frame or data.table with time and value columns
#' @param time_var The name of the time variable column (string)
#' @param value_var The name of the numeric value column to transform (string)
#' @param range Optional numeric range to scale result (e.g., c(0, 1))
#' @param smooth Logical. If TRUE, applies 1/f-style fractal smoothing (default = TRUE)
#' @param seed Optional seed for reproducibility
#' @return A data.table with original time index and a new column `fractal_y`
#' @export

fractalize_series <- function(data, time_var = "date", value_var = "y", range = NULL, smooth = TRUE, seed = NULL) {
  if (!requireNamespace("data.table", quietly = TRUE)) stop("data.table required.")
  library(data.table)
  library(stats)

  if (!inherits(data, "data.table")) data <- as.data.table(data)
  if (!is.null(seed)) set.seed(seed)

  y <- data[[value_var]]
  n <- length(y)

  # Step 1: Create 1/f pink noise filter
  fft_y <- fft(y)
  freq <- 1:(n %/% 2)
  filter <- 1 / sqrt(freq)
  filter_full <- c(1, filter, rev(filter[1:(n - length(filter) - 1)]))

  # Step 2: Apply filter in frequency domain
  smoothed_fft <- fft_y * filter_full
  smoothed_y <- Re(fft(smoothed_fft, inverse = TRUE)) / n

  # Step 3: Optional range rescaling
  if (!is.null(range)) {
    min_val <- min(smoothed_y, na.rm = TRUE)
    max_val <- max(smoothed_y, na.rm = TRUE)
    smoothed_y <- (smoothed_y - min_val) / (max_val - min_val)  # scale to [0, 1]
    smoothed_y <- smoothed_y * (range[2] - range[1]) + range[1]
  }

  # Step 4: Return result
  out <- data.table(
    time = data[[time_var]],
    fractal_y = smoothed_y
  )
  return(out)
}
