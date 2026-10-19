#' Target of grid square statistics of the Population Census
#'
#' `census_grid_target()` and `census_grid_target_raw()` declare a target of a
#' 'targets' pipeline whose value is
#' `census_grid_get(year, grid_size, table_code)`. The target is rerun when the
#' arguments or the installed version of locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `census_grid_target()`, a
#'   string for `census_grid_target_raw()`.
#' @inheritParams census_grid_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' census_grid_target(population_2020, 2020, "500m", "001-01")
census_grid_target <- function(name, year, grid_size, table_code, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  census_grid_target_raw(
    name = name,
    year = year,
    grid_size = grid_size,
    table_code = table_code,
    ...
  )
}

#' @rdname census_grid_target
#' @export
census_grid_target_raw <- function(name, year, grid_size, table_code, ...) {
  check_string(name)
  table <- check_census_grid_table(year, grid_size, table_code)

  command <- rlang::call2(
    "census_grid_get",
    year = table$year,
    grid_size = table$grid_size,
    table_code = table$table_code,
    .ns = "locationchoicedatajp"
  )
  string <- paste(
    c(
      deparse(command),
      table$stats_id,
      as.character(utils::packageVersion("locationchoicedatajp"))
    ),
    collapse = "\n"
  )
  targets::tar_target_raw(name = name, command = command, string = string, ...)
}
