#' Target of commuting flows of the Population Census
#'
#' `census_commuting_target()` and `census_commuting_target_raw()` declare a
#' target of a 'targets' pipeline whose value is
#' `census_commuting_get(year, purpose)`. The target is rerun when the
#' arguments, the table on e-Stat, or the installed version of
#' locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `census_commuting_target()`, a
#'   string for `census_commuting_target_raw()`.
#' @inheritParams census_commuting_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' census_commuting_target(commuting_2020, 2020, "work")
census_commuting_target <- function(name, year, purpose, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  census_commuting_target_raw(name = name, year = year, purpose = purpose, ...)
}

#' @rdname census_commuting_target
#' @export
census_commuting_target_raw <- function(name, year, purpose, ...) {
  check_string(name)
  table <- check_census_commuting_table(year, purpose)

  command <- rlang::call2(
    "census_commuting_get",
    year = table$year,
    purpose = table$purpose,
    .ns = "locationchoicedatajp"
  )
  string <- paste(
    c(
      deparse(command),
      table$stats_data_id,
      table$item_code,
      as.character(utils::packageVersion("locationchoicedatajp"))
    ),
    collapse = "\n"
  )
  targets::tar_target_raw(name = name, command = command, string = string, ...)
}
