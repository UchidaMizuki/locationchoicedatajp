#' Sizes of grid squares
#'
#' `grid_sizes()` lists the sizes of the standard grid squares (標準地域メッシュ)
#' that the functions of locationchoicedatajp take: the basic squares (1 km)
#' and their halves (500 m) and quarters (250 m). They are the sizes on which
#' the Population Census, the Economic Census (1 km and 500 m), and the future
#' population of National Land Numerical Information are published, and they
#' nest exactly. Coarser squares (5 km and over) are coarser than many
#' municipalities, and finer squares (125 m) have no published statistics.
#'
#' The functions have no default size, as the size is a choice of the model.
#'
#' @returns A character vector of sizes, from the coarsest.
#' @export
#' @examples
#' grid_sizes()
grid_sizes <- function() {
  c("1km", "500m", "250m")
}

check_grid_size <- function(grid_size, call = rlang::caller_env()) {
  rlang::check_required(grid_size, call = call)
  rlang::arg_match(grid_size, grid_sizes(), error_call = call)
}
