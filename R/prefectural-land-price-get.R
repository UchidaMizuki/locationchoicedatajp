#' Get prefectural land prices
#'
#' Returns the sites of the prefectural land price survey (都道府県地価調査) of
#' National Land Numerical Information in a year, one row per site, as
#' published. The first call for a year downloads the file of that year's
#' release (via ksjdata) and builds the table, which is then cached.
#'
#' The survey is a separate source from the official land prices of
#' [land_price_get()] (地価公示): its prices are as of July 1, not January 1,
#' and its sites are chosen by the prefectures. The year is taken from its own
#' release, and the sites are not summarised.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 都道府県地価調査データ, by the Ministry of Land, Infrastructure, Transport and
#' Tourism), and processed data must say that they were processed.
#'
#' @param year Reference year, from 2006 to the latest release. See
#'   [prefectural_land_price_files()] for the available years. To get several
#'   years, iterate over them: the coordinate reference system differs between
#'   releases.
#'
#' @return An `sf` tibble with one row per site, with the columns of
#'   [land_price_get()]:
#'
#'   * `year`, `release`: The reference year (prices are as of July 1) and the
#'     year of the release, which is `year`.
#'   * `city_code`: Five-digit municipality code, as published for that year.
#'   * `use_code`: Three-digit use of the site (用途区分), as published: `000`
#'     住宅地, `003` 宅地見込地, `005` 商業地, `009` 工業地, and `020` 林地, and,
#'     until 2012, also `007` and `010`.
#'   * `site_number`: Three-digit serial number of the site within its
#'     municipality and use, as published.
#'   * `price_jpy_per_m2`: The price in yen per square meter. Forest land
#'     (`020`) is published in yen per 10 ares, and is divided by 1,000. One
#'     site in 2008 has a price of 0, as published.
#'   * `geometry`: The point of the site, in the coordinate reference system of
#'     the release: JGD2000 (EPSG:4612) until 2022 and JGD2011 (EPSG:6668) from
#'     2023. The files until 2012 have no `.prj` file, and are set to JGD2000.
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 都道府県地価調査データ (L02):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L02-2026.html>. The
#'   terms of use are on
#'   <https://nlftp.mlit.go.jp/ksj/other/agreement_01.html>.
#'
#' @seealso [prefectural_land_price_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' prefectural_land_price_get(2020)
#'
#' @export
prefectural_land_price_get <- function(year) {
  check_land_price_year(year, prefectural_land_price_files())
  land_price_inform_terms("L02")
  prefectural_land_price_get_archive(year)
}

# nocov start
prefectural_land_price_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = prefectural_land_price_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "prefectural-land-price"
  )
}
# nocov end

#' Files of the prefectural land prices
#'
#' `prefectural_land_price_files()` lists the file of each year of
#' [prefectural_land_price_get()], as [land_price_files()] does for 地価公示. It
#' is used by the bundled pipeline.
#'
#' @inherit land_price_files return
#' @keywords internal
#' @export
#' @examples
#' prefectural_land_price_files()
prefectural_land_price_files <- function() {
  land_price_read_files("prefectural-land-price")
}

#' Name of the target of a year of prefectural land prices
#'
#' `prefectural_land_price_target_name()` gives the name of the target of a
#' year in the bundled pipeline: `2020` becomes `prefectural_land_price_2020`.
#'
#' @inheritParams land_price_target_name
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' prefectural_land_price_target_name(2020)
prefectural_land_price_target_name <- function(year) {
  paste0("prefectural_land_price_", year)
}

#' Target of prefectural land prices
#'
#' `prefectural_land_price_target()` and `prefectural_land_price_target_raw()`
#' declare a target of a 'targets' pipeline whose value is
#' `prefectural_land_price_get(year)`. The target is rerun when `year`, the URL
#' of the file of that year, or the installed version of locationchoicedatajp
#' change.
#'
#' @inheritParams land_price_target
#' @returns A target object.
#' @export
#' @examples
#' prefectural_land_price_target(prefectural_land_price_2020, 2020)
prefectural_land_price_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  prefectural_land_price_target_raw(name = name, year = year, ...)
}

#' @rdname prefectural_land_price_target
#' @export
prefectural_land_price_target_raw <- function(name, year, ...) {
  check_string(name)
  files <- prefectural_land_price_files()
  check_land_price_year(year, files)

  command <- rlang::call2(
    "prefectural_land_price_get",
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
