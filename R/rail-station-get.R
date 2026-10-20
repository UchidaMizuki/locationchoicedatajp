#' Get railway stations
#'
#' Returns the railway stations of National Land Numerical Information (鉄道,
#' N02) in a year, one row per station of a line, as published. The first call
#' for a year downloads the file of that year's release (via ksjdata) and
#' builds the table, which is then cached.
#'
#' A station served by several lines has a row for each line. Stations are
#' lines (the extent of their platforms) as published; take a point of them or
#' group them by `station_group_code` as the model needs.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 鉄道データ, by the Ministry of Land, Infrastructure, Transport and Tourism),
#' and processed data must say that they were processed.
#'
#' @param year Reference year: 2006 to 2008, and 2011 to the latest release.
#'   Releases are as of December 31 of their year. See [rail_station_files()]
#'   for the available years.
#'
#' @return An `sf` tibble with one row per station of a line:
#'
#'   * `year`, `release`: The reference year and the year of its release,
#'     which is `year`.
#'   * `railway_type_code`: 鉄道区分 (N02_001), as published.
#'   * `operator_type_code`: 事業者種別 (N02_002), as published.
#'   * `line_name`, `operator_name`, `station_name`: 路線名, 運営会社, and 駅名,
#'     as published.
#'   * `station_code`, `station_group_code`: 駅コード and グループコード,
#'     published from 2022 and `NA` before. A group is the stations of the same
#'     name within 300 m.
#'   * `geometry`: The station as a line, in the coordinate reference system of
#'     the release: JGD2011 (EPSG:6668) from 2015. The files until 2014 have no
#'     `.prj` file, and are set to JGD2000 (EPSG:4612), the datum of the
#'     catalog.
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 鉄道データ (N02):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N02-2025.html>. See
#'   [data_sources()] for the terms of use.
#'
#' @seealso [rail_station_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' rail_station_get(2020)
#'
#' @export
rail_station_get <- function(year) {
  check_rail_station_year(year)
  inform_terms("rail_station_get")
  rail_station_get_archive(year)
}

# nocov start
rail_station_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = rail_station_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "rail-station"
  )
}
# nocov end

check_rail_station_year <- function(year, call = rlang::caller_env()) {
  rlang::check_required(year, call = call)
  check_number_whole(year, call = call)
  years <- rail_station_files()$year
  if (!year %in% years) {
    cli::cli_abort(
      c(
        "{.arg year} must be a year with railway stations.",
        i = "Available years: {years}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

#' Files of the railway stations
#'
#' `rail_station_files()` lists the file of each year of [rail_station_get()]:
#' the release of 鉄道 (N02) in [ksjdata::ksj_available], its layer of
#' stations, the EPSG code of its coordinate reference system, the number of
#' stations, and its URL. It is used by the bundled pipeline.
#'
#' @returns A tibble with columns `year`, `file_name`, `layer`, `epsg`,
#'   `n_stations`, and `url`.
#' @keywords internal
#' @export
#' @examples
#' rail_station_files()
rail_station_files <- function() {
  path <- system.file(
    "tarchives",
    "rail-station",
    "files.csv",
    package = "locationchoicedatajp"
  )
  files <- utils::read.csv(
    path,
    colClasses = c(year = "integer", epsg = "integer", n_stations = "integer"),
    encoding = "UTF-8"
  )
  ksj <- ksjdata::ksj_available
  files$url <- ksj$url[match(files$file_name, ksj$file_name)]
  tibble::as_tibble(files)
}

#' Name of the target of a year of railway stations
#'
#' `rail_station_target_name()` gives the name of the target of a year in the
#' bundled pipeline: `2020` becomes `rail_station_2020`.
#'
#' @param year Years: values of `year` in [rail_station_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' rail_station_target_name(2020)
rail_station_target_name <- function(year) {
  paste0("rail_station_", year)
}

#' Target of railway stations
#'
#' `rail_station_target()` and `rail_station_target_raw()` declare a target of
#' a 'targets' pipeline whose value is `rail_station_get(year)`. The target is
#' rerun when `year`, the URL of the file of that year, or the installed version
#' of locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `rail_station_target()`, a
#'   string for `rail_station_target_raw()`.
#' @inheritParams rail_station_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' rail_station_target(stations_2020, 2020)
rail_station_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  rail_station_target_raw(name = name, year = year, ...)
}

#' @rdname rail_station_target
#' @export
rail_station_target_raw <- function(name, year, ...) {
  check_string(name)
  check_rail_station_year(year)
  files <- rail_station_files()

  command <- rlang::call2(
    "rail_station_get",
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
