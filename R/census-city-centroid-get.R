#' Get population centroids of municipalities
#'
#' Returns the population centroid (人口重心) of each municipality published by
#' the Statistics Bureau for a census, as an `sf` tibble of points. They are the
#' representative points of municipalities, for example for distances between
#' them or to grid squares. The first call for a year downloads the workbook and
#' builds the table, which is then cached.
#'
#' The centroid of a municipality is the mean of the centres of its basic unit
#' blocks (基本単位区, about two million in Japan) weighted by their population.
#' Municipalities without residents have no centroid and no row (in 2015, 富岡町,
#' 大熊町, 双葉町, and 浪江町; in 2020, 双葉町). The centroid of a municipality
#' of islands or with a long coast can lie in the sea or outside it (8 of 1,895
#' municipalities in 2020, for example 小笠原村).
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (the Statistics Bureau of Japan), and
#' processed data must say that they were processed.
#'
#' @param year The year of the census: 2015 or 2020.
#'
#' @return An `sf` tibble with one row per municipality:
#'
#'   * `year`: The year of the census (integer), as of October 1.
#'   * `release`: The year of the release the values are taken from (integer).
#'     It is `year`.
#'   * `city_code`: Five-digit municipality code, as published. Designated
#'     cities have a row for the whole city and one for each ward.
#'   * `geometry`: The centroid, in JGD2000 (EPSG:4612). The workbook of 2020
#'     states this datum; that of 2015 does not, and is set to the same, the
#'     datum of the census.
#'
#' @source Statistics Bureau of Japan, population centroids of the Population
#'   Census (人口重心): 2015,
#'   <https://www.stat.go.jp/data/kokusei/topics/zuhyou/topi102.xls>, and 2020,
#'   <https://www.stat.go.jp/data/kokusei/topics/zuhyou/topics135_10.xlsx>,
#'   from <https://www.stat.go.jp/data/kokusei/topics/topi135.html>. The terms
#'   of use of the Statistics Bureau, the Public Data License (Version 1.0) and
#'   compatible with CC BY 4.0, are on <https://www.stat.go.jp/info/riyou.html>.
#'
#' @seealso [census_city_centroid_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' centroids <- census_city_centroid_get(2020)
#'
#' # Great-circle distances between the centroids, in meters
#' sf::st_distance(centroids[1:3, ])
#'
#' @export
census_city_centroid_get <- function(year) {
  check_census_city_centroid_year(year)
  census_city_centroid_inform_terms()
  census_city_centroid_get_archive(year)
}

# nocov start
census_city_centroid_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = census_city_centroid_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "census-city-centroid"
  )
}
# nocov end

check_census_city_centroid_year <- function(year, call = rlang::caller_env()) {
  rlang::check_required(year, call = call)
  check_number_whole(year, call = call)
  years <- census_city_centroid_files()$year
  if (!year %in% years) {
    cli::cli_abort(
      c(
        "{.arg year} must be a year with population centroids.",
        i = "Available years: {years}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

census_city_centroid_inform_terms <- function() {
  cli::cli_inform(
    c(
      "Terms of use of the Statistics Bureau: the Public Data License (Version 1.0), compatible with CC BY 4.0.",
      i = "{.url https://www.stat.go.jp/info/riyou.html}"
    ),
    .frequency = "once",
    .frequency_id = "locationchoicedatajp_terms_stat"
  )
}

#' Files of the population centroids
#'
#' `census_city_centroid_files()` lists the workbook of each year of
#' [census_city_centroid_get()]: its URL and how its angles are written
#' (`"decimal"` degrees or `"dms"` as DDDMMSS.ss). It is used by the bundled
#' pipeline.
#'
#' @returns A tibble with columns `year`, `url`, and `angle`.
#' @keywords internal
#' @export
#' @examples
#' census_city_centroid_files()
census_city_centroid_files <- function() {
  path <- system.file(
    "tarchives",
    "census-city-centroid",
    "files.csv",
    package = "locationchoicedatajp"
  )
  data <- utils::read.csv(path, colClasses = "character", encoding = "UTF-8")
  data$year <- as.integer(data$year)
  tibble::as_tibble(data)
}

#' Name of the target of population centroids
#'
#' `census_city_centroid_target_name()` gives the name of the target of a year
#' in the bundled pipeline: `2020` becomes `census_city_centroid_2020`.
#'
#' @param year Years: values of `year` in [census_city_centroid_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' census_city_centroid_target_name(2020)
census_city_centroid_target_name <- function(year) {
  paste0("census_city_centroid_", year)
}

#' Target of population centroids of municipalities
#'
#' `census_city_centroid_target()` and `census_city_centroid_target_raw()`
#' declare a target of a 'targets' pipeline whose value is
#' `census_city_centroid_get(year)`. The target is rerun when `year`, the URL
#' of the workbook, or the installed version of locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `census_city_centroid_target()`,
#'   a string for `census_city_centroid_target_raw()`.
#' @inheritParams census_city_centroid_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' census_city_centroid_target(centroids_2020, 2020)
census_city_centroid_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  census_city_centroid_target_raw(name = name, year = year, ...)
}

#' @rdname census_city_centroid_target
#' @export
census_city_centroid_target_raw <- function(name, year, ...) {
  check_string(name)
  check_census_city_centroid_year(year)
  files <- census_city_centroid_files()

  command <- rlang::call2(
    "census_city_centroid_get",
    year = year,
    .ns = "locationchoicedatajp"
  )
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
