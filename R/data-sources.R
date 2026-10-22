#' Sources of the tables
#'
#' `data_sources()` lists the source of each table of locationchoicedatajp: one
#' row per getter, with its publisher, terms of use, and a line of attribution.
#' `data_attribution()` gives the lines of attribution of the getters used, to
#' credit the sources in publications.
#'
#' The terms of National Land Numerical Information are set for each release,
#' so `license_note` gives those of the releases that the getter uses, as
#' stated on the pages of the dataset: for example, 地価公示 is CC BY 4.0 from
#' 2019 and 商用可 before. Releases that cannot be used commercially (非商用)
#' are not used. The terms of e-Stat and of the Statistics Bureau are
#' compatible with CC BY 4.0.
#'
#' Every source asks for credit, and data that are processed must say so. The
#' tables of locationchoicedatajp are processed (reshaped, renamed, and
#' converted), so the lines say that they were processed (加工して作成).
#' Complying with the terms is up to you; this package does not give legal
#' advice.
#'
#' @param functions Names of getters, such as `"land_price_get"`, or `NULL`
#'   (the default) for all of them.
#'
#' @returns `data_sources()` returns a tibble with one row per getter:
#'   `function_name`, `source_name`, `publisher`, `source_url`,
#'   `license_name`, `license_note`, `license_url`, and `attribution`.
#'
#'   `data_attribution()` returns a character vector of the distinct lines of
#'   attribution of `functions`.
#' @export
#' @examples
#' data_sources()
#'
#' data_attribution(c("land_price_get", "census_grid_get"))
data_sources <- function() {
  path <- system.file("sources.csv", package = "locationchoicedatajp")
  sources <- utils::read.csv(
    path,
    colClasses = "character",
    na.strings = "",
    encoding = "UTF-8"
  )
  tibble::as_tibble(sources)
}

#' @rdname data_sources
#' @export
data_attribution <- function(functions = NULL) {
  check_character(functions, allow_null = TRUE)
  sources <- data_sources()
  if (!is.null(functions)) {
    unknown <- setdiff(functions, sources$function_name)
    if (length(unknown) > 0) {
      cli::cli_abort(
        c(
          "{.arg functions} must be getters of locationchoicedatajp.",
          x = "Unknown: {.val {unknown}}."
        ),
        class = "locationchoicedatajp_error_function"
      )
    }
    sources <- sources[sources$function_name %in% functions, ]
  }
  unique(sources$attribution)
}

# Shows the terms of use of the source of a getter, once per session and
# source.
inform_terms <- function(function_name) {
  sources <- data_sources()
  source <- sources[sources$function_name == function_name, ]
  cli::cli_inform(
    c(
      "Terms of use of {source$source_name} ({source$publisher}): {source$license_name}",
      i = "{source$license_note}",
      i = "{.url {source$license_url}}",
      i = "To credit the source, see {.run locationchoicedatajp::data_attribution(\"{function_name}\")}."
    ),
    .frequency = "once",
    .frequency_id = paste0("locationchoicedatajp_terms_", source$source_name)
  )
}
