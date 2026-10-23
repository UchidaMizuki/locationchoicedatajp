#' Get municipal offices and public meeting facilities
#'
#' Returns the municipal offices and public meeting facilities of National Land
#' Numerical Information (市町村役場等及び公的集会施設, P05) in a year, one row
#' per facility, as published. The first call for a year downloads the file of
#' that year's release (via ksjdata) and builds the table, which is then
#' cached.
#'
#' The file has a layer per prefecture in the same layout, which are bound. The
#' offices (`facility_type_code` `"1"`) are those of municipalities and of the
#' wards of designated cities; the office of a designated city has the code of
#' the ward it is in. Codes are kept as published, including a few that are not
#' of the municipality of the facility.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 市町村役場等及び公的集会施設データ, by the Ministry of Land, Infrastructure,
#' Transport and Tourism), and processed data must say that they were
#' processed.
#'
#' @param year Reference year (fiscal year). See [public_facility_files()] for
#'   the available years. The release of 2010 is left out, as it may not be
#'   used commercially.
#'
#' @return An `sf` tibble with one row per facility:
#'
#'   * `year`, `release`: The reference year and the year of its release,
#'     which is `year`.
#'   * `city_code`: 行政区域コード (P05_001) of the municipality, as
#'     published.
#'   * `facility_type_code`: 施設分類 (P05_002): `"1"` 本庁 (the office of a
#'     municipality or a ward), `"2"` 支所、出張所、連絡所, `"3"` other
#'     facilities with administrative services, `"4"` 公立公民館, `"5"` other
#'     public meeting facilities (集会施設).
#'   * `facility_name`, `address`: 名称 and 所在地, as published.
#'   * `geometry`: The facility as a point, in JGD2011 (EPSG:6668).
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 市町村役場等及び公的集会施設データ (P05):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P05-2022.html>. See
#'   [data_sources()] for the terms of use.
#'
#' @seealso [public_facility_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' public_facility_get(2022)
#'
#' @export
public_facility_get <- function(year) {
  check_public_facility_year(year)
  inform_terms("public_facility_get")
  public_facility_get_archive(year)
}

# nocov start
public_facility_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = public_facility_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "public-facility"
  )
}
# nocov end

check_public_facility_year <- function(year, call = rlang::caller_env()) {
  rlang::check_required(year, call = call)
  check_number_whole(year, call = call)
  years <- public_facility_files()$year
  if (!year %in% years) {
    cli::cli_abort(
      c(
        "{.arg year} must be a year with public facilities.",
        i = "Available years: {years}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

#' Files of the municipal offices and public meeting facilities
#'
#' `public_facility_files()` lists the file of each year of
#' [public_facility_get()]: the national release of 市町村役場等及び公的集会施設
#' (P05) in [ksjdata::ksj_available], the prefix of its layers (one per
#' prefecture), the EPSG code of its coordinate reference system, the number of
#' facilities, and its URL. It is used by the bundled pipeline.
#'
#' @returns A tibble with columns `year`, `file_name`, `layer_prefix`, `epsg`,
#'   `n_facilities`, and `url`.
#' @keywords internal
#' @export
#' @examples
#' public_facility_files()
public_facility_files <- function() {
  path <- system.file(
    "tarchives",
    "public-facility",
    "files.csv",
    package = "locationchoicedatajp"
  )
  files <- utils::read.csv(
    path,
    colClasses = c(
      year = "integer",
      epsg = "integer",
      n_facilities = "integer"
    ),
    encoding = "UTF-8"
  )
  ksj <- ksjdata::ksj_available
  files$url <- ksj$url[match(files$file_name, ksj$file_name)]
  tibble::as_tibble(files)
}

#' Name of the target of a year of public facilities
#'
#' `public_facility_target_name()` gives the name of the target of a year in
#' the bundled pipeline: `2022` becomes `public_facility_2022`.
#'
#' @param year Years: values of `year` in [public_facility_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' public_facility_target_name(2022)
public_facility_target_name <- function(year) {
  paste0("public_facility_", year)
}

#' Target of municipal offices and public meeting facilities
#'
#' `public_facility_target()` and `public_facility_target_raw()` declare a
#' target of a 'targets' pipeline whose value is `public_facility_get(year)`.
#' The target is rerun when `year`, the URL of the file of that year, or the
#' installed version of locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `public_facility_target()`, a
#'   string for `public_facility_target_raw()`.
#' @inheritParams public_facility_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' public_facility_target(facilities_2022, 2022)
public_facility_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  public_facility_target_raw(name = name, year = year, ...)
}

#' @rdname public_facility_target
#' @export
public_facility_target_raw <- function(name, year, ...) {
  check_string(name)
  check_public_facility_year(year)
  files <- public_facility_files()

  command <- rlang::call2(
    "public_facility_get",
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
