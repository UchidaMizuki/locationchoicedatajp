#' Target of the crosswalk of grid squares to municipalities
#'
#' `grid_city_target()` and `grid_city_target_raw()` declare a target of a
#' 'targets' pipeline whose value is `grid_city_get(date, grid_size)`. The
#' target is rerun when the arguments, the URLs of the files of the release, or
#' the installed version of locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `grid_city_target()`, a string
#'   for `grid_city_target_raw()`.
#' @inheritParams grid_city_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' grid_city_target(grid_city_2020, "2020-10-01")
grid_city_target <- function(name, date, grid_size = c("500m", "1km"), ...) {
  name <- targets::tar_deparse_language(substitute(name))
  grid_city_target_raw(name = name, date = date, grid_size = grid_size, ...)
}

#' @rdname grid_city_target
#' @export
grid_city_target_raw <- function(
  name,
  date,
  grid_size = c("500m", "1km"),
  ...
) {
  check_string(name)
  date <- check_boundary_date(date)
  grid_size <- rlang::arg_match(grid_size)

  command <- rlang::call2(
    "grid_city_get",
    date = format(date),
    grid_size = grid_size,
    .ns = "locationchoicedatajp"
  )
  # The URLs rerun the target when an update of ksjdata replaces a file, even
  # if the version of locationchoicedatajp is unchanged.
  files <- grid_city_files()
  files <- files[files$boundary_date == grid_city_release_date(date, files), ]
  string <- paste(
    c(
      deparse(command),
      files$url,
      as.character(utils::packageVersion("locationchoicedatajp"))
    ),
    collapse = "\n"
  )
  targets::tar_target_raw(name = name, command = command, string = string, ...)
}
