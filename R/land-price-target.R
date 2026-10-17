#' Target of land prices
#'
#' `land_price_target()` and `land_price_target_raw()` declare a target of a
#' 'targets' pipeline whose value is `land_price_get(year)`. The target is
#' rerun when `year`, the URLs of the files of those years, or the installed
#' version of locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `land_price_target()`, a string
#'   for `land_price_target_raw()`.
#' @inheritParams land_price_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' land_price_target(land_price, c(2010, 2015, 2020))
land_price_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  land_price_target_raw(name = name, year = year, ...)
}

#' @rdname land_price_target
#' @export
land_price_target_raw <- function(name, year, ...) {
  check_string(name)
  check_land_price_year(year)

  command <- rlang::call2(
    "land_price_get",
    year = year,
    .ns = "locationchoicedatajp"
  )
  # The URLs rerun the target when an update of ksjdata replaces a file, even
  # if the version of locationchoicedatajp is unchanged.
  files <- land_price_files()
  string <- paste(
    c(
      deparse(command),
      files$url[files$year %in% year],
      as.character(utils::packageVersion("locationchoicedatajp"))
    ),
    collapse = "\n"
  )
  targets::tar_target_raw(name = name, command = command, string = string, ...)
}
