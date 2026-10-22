#' Get railway lines
#'
#' Returns the railway lines of National Land Numerical Information (鉄道, N02)
#' in a year, one row per section of a line, as published. The first call for a
#' year downloads the file of that year's release (via ksjdata) and builds the
#' table, which is then cached.
#'
#' A line is published as sections, and a track shared by several lines has a
#' section for each line. The stations of the same files are
#' [rail_station_get()].
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 鉄道データ, by the Ministry of Land, Infrastructure, Transport and Tourism),
#' and processed data must say that they were processed.
#'
#' @param year Reference year: 2006 to 2008, and 2011 to the latest release.
#'   Releases are as of December 31 of their year. See [rail_line_files()] for
#'   the available years.
#'
#' @return An `sf` tibble with one row per section of a line:
#'
#'   * `year`, `release`: The reference year and the year of its release,
#'     which is `year`.
#'   * `railway_type_code`: 鉄道区分 (N02_001): `"11"` 普通鉄道JR, `"12"`
#'     普通鉄道, `"13"` 鋼索鉄道, `"14"` 懸垂式鉄道, `"15"` 跨座式鉄道,
#'     `"16"` 案内軌条式鉄道, `"17"` 無軌条鉄道, `"21"` 軌道, `"22"`
#'     懸垂式モノレール, `"23"` 跨座式モノレール, `"24"` 案内軌条式, `"25"`
#'     浮上式.
#'   * `operator_type_code`: 事業者種別 (N02_002): `"1"` JRの新幹線, `"2"`
#'     JR在来線, `"3"` 公営鉄道, `"4"` 民営鉄道, `"5"` 第三セクター.
#'   * `line_name`, `operator_name`: 路線名 and 運営会社, as published.
#'   * `geometry`: The section as a line, in the coordinate reference system of
#'     the release: JGD2011 (EPSG:6668) from 2015. The files until 2014 have no
#'     `.prj` file, and are set to JGD2000 (EPSG:4612), the datum of the
#'     catalog.
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 鉄道データ (N02):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N02-2025.html>. See
#'   [data_sources()] for the terms of use.
#'
#' @seealso [rail_line_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' rail_line_get(2020)
#'
#' @export
rail_line_get <- function(year) {
  check_rail_line_year(year)
  inform_terms("rail_line_get")
  rail_line_get_archive(year)
}

# nocov start
rail_line_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = rail_line_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "rail-line"
  )
}
# nocov end

check_rail_line_year <- function(year, call = rlang::caller_env()) {
  rlang::check_required(year, call = call)
  check_number_whole(year, call = call)
  years <- rail_line_files()$year
  if (!year %in% years) {
    cli::cli_abort(
      c(
        "{.arg year} must be a year with railway lines.",
        i = "Available years: {years}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

#' Files of the railway lines
#'
#' `rail_line_files()` lists the file of each year of [rail_line_get()]: the
#' release of 鉄道 (N02) in [ksjdata::ksj_available], its layer of sections of
#' lines, the EPSG code of its coordinate reference system, the number of
#' sections, and its URL. It is used by the bundled pipeline.
#'
#' @returns A tibble with columns `year`, `file_name`, `layer`, `epsg`,
#'   `n_sections`, and `url`.
#' @keywords internal
#' @export
#' @examples
#' rail_line_files()
rail_line_files <- function() {
  path <- system.file(
    "tarchives",
    "rail-line",
    "files.csv",
    package = "locationchoicedatajp"
  )
  files <- utils::read.csv(
    path,
    colClasses = c(year = "integer", epsg = "integer", n_sections = "integer"),
    encoding = "UTF-8"
  )
  ksj <- ksjdata::ksj_available
  files$url <- ksj$url[match(files$file_name, ksj$file_name)]
  tibble::as_tibble(files)
}

#' Name of the target of a year of railway lines
#'
#' `rail_line_target_name()` gives the name of the target of a year in the
#' bundled pipeline: `2020` becomes `rail_line_2020`.
#'
#' @param year Years: values of `year` in [rail_line_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' rail_line_target_name(2020)
rail_line_target_name <- function(year) {
  paste0("rail_line_", year)
}

#' Target of railway lines
#'
#' `rail_line_target()` and `rail_line_target_raw()` declare a target of a
#' 'targets' pipeline whose value is `rail_line_get(year)`. The target is rerun
#' when `year`, the URL of the file of that year, or the installed version of
#' locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `rail_line_target()`, a string
#'   for `rail_line_target_raw()`.
#' @inheritParams rail_line_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' rail_line_target(lines_2020, 2020)
rail_line_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  rail_line_target_raw(name = name, year = year, ...)
}

#' @rdname rail_line_target
#' @export
rail_line_target_raw <- function(name, year, ...) {
  check_string(name)
  check_rail_line_year(year)
  files <- rail_line_files()

  command <- rlang::call2(
    "rail_line_get",
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
