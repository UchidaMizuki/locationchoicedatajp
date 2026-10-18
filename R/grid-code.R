#' Code of the grid square of points
#'
#' `grid_code()` gives the code of the grid square (地域メッシュ・コード) that
#' contains each point, for example the sites of [land_price_get()]. It is the
#' step that assigns every point source to grid squares, so that they join the
#' tables on grid squares and [grid_city_get()].
#'
#' @param x An `sf` object or `sfc` of points with longitude and latitude, such
#'   as JGD2011 or JGD2000. Their difference is far smaller than a grid square,
#'   so the coordinates are used as they are.
#' @inheritParams grid_city_get
#' @returns A character vector of codes, nine digits for 500 m and eight digits
#'   for 1 km.
#' @export
#' @examplesIf interactive()
#' sites <- land_price_get(2020)
#' sites$grid_code <- grid_code(sites)
grid_code <- function(x, grid_size = c("500m", "1km")) {
  grid_size <- rlang::arg_match(grid_size)
  geometry <- sf::st_geometry(x)
  if (!all(sf::st_geometry_type(geometry) == "POINT")) {
    cli::cli_abort(
      "{.arg x} must have points.",
      class = "locationchoicedatajp_error_geometry"
    )
  }
  if (!isTRUE(sf::st_is_longlat(geometry))) {
    cli::cli_abort(
      "{.arg x} must have longitude and latitude.",
      class = "locationchoicedatajp_error_geometry"
    )
  }
  coords <- sf::st_coordinates(geometry)
  as.character(jpgrid::coords_to_grid(coords[, "X"], coords[, "Y"], grid_size))
}
