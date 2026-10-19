#' Get land prices summarised by grid square
#'
#' Summarises the sites of [land_price_get()] in a year by grid square and use:
#' the number of sites, and the median and the geometric mean of their prices.
#' It is a summary, not an observation: use [land_price_get()] for the sites.
#'
#' Sites cover only some grid squares, so most squares have no row, and most
#' squares with a row have a single site, especially at 500 m. Squares are not
#' filled in. Prices are skewed, so the geometric mean (the exponential of the
#' mean of log prices) is given rather than the arithmetic mean.
#'
#' @inheritParams land_price_get
#' @inheritParams grid_city_get
#'
#' @return A tibble with one row per grid square and use with at least one
#'   site:
#'
#'   * `year`, `release`: As in [land_price_get()].
#'   * `grid_code`: The code of the grid square (see [grid_code()]).
#'   * `use_code`: The use of the sites, as in [land_price_get()]. Uses are
#'     not mixed.
#'   * `n_points`: The number of sites.
#'   * `price_median_jpy_per_m2`: The median price of the sites, in yen per
#'     square meter.
#'   * `price_geometric_mean_jpy_per_m2`: The geometric mean price of the
#'     sites, in yen per square meter.
#'
#' @inherit land_price_get source
#'
#' @seealso [land_price_grid_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' land_price_grid_get(2020, "1km")
#'
#' @export
land_price_grid_get <- function(year, grid_size) {
  grid_size <- check_grid_size(grid_size)
  sites <- land_price_get(year)
  land_price_grid_summarise(sites, grid_size)
}

land_price_grid_summarise <- function(sites, grid_size) {
  sites$grid_code <- grid_code(sites, grid_size)
  sites |>
    sf::st_drop_geometry() |>
    dplyr::summarise(
      n_points = dplyr::n(),
      price_median_jpy_per_m2 = stats::median(.data$price_jpy_per_m2),
      price_geometric_mean_jpy_per_m2 = exp(mean(log(.data$price_jpy_per_m2))),
      .by = c("year", "release", "grid_code", "use_code")
    ) |>
    dplyr::arrange(.data$grid_code, .data$use_code)
}

#' Target of land prices summarised by grid square
#'
#' `land_price_grid_target()` and `land_price_grid_target_raw()` declare a
#' target of a 'targets' pipeline whose value is
#' `land_price_grid_get(year, grid_size)`. The target is rerun when the
#' arguments, the URL of the file of that year, or the installed version of
#' locationchoicedatajp change.
#'
#' @inheritParams land_price_target
#' @inheritParams land_price_grid_get
#' @returns A target object.
#' @export
#' @examples
#' land_price_grid_target(land_price_grid_2020, 2020, "1km")
land_price_grid_target <- function(
  name,
  year,
  grid_size,
  ...
) {
  name <- targets::tar_deparse_language(substitute(name))
  land_price_grid_target_raw(
    name = name,
    year = year,
    grid_size = grid_size,
    ...
  )
}

#' @rdname land_price_grid_target
#' @export
land_price_grid_target_raw <- function(
  name,
  year,
  grid_size,
  ...
) {
  check_string(name)
  check_land_price_year(year)
  grid_size <- check_grid_size(grid_size)

  command <- rlang::call2(
    "land_price_grid_get",
    year = year,
    grid_size = grid_size,
    .ns = "locationchoicedatajp"
  )
  files <- land_price_files()
  string <- paste(
    c(
      deparse(command),
      files$url[files$year == year],
      as.character(utils::packageVersion("locationchoicedatajp"))
    ),
    collapse = "\n"
  )
  targets::tar_target_raw(name = name, command = command, string = string, ...)
}
