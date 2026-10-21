#' Get schools
#'
#' Returns the schools of National Land Numerical Information (学校, P29) in a
#' year, one row per site, as published. The first call for a year downloads
#' the file of that year's release (via ksjdata) and builds the table, which is
#' then cached.
#'
#' The schools are those of the School Education Act, from kindergartens to
#' universities, specialized training colleges (専修学校), and miscellaneous
#' schools (各種学校), and 幼保連携型認定こども園. A school with several
#' campuses has a row for each from 2023 (`campus_code`), and a school and its
#' campus identify a row. In 2021, 550 rows share their `school_code` with
#' another row, and one has none.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 学校データ, by the Ministry of Land, Infrastructure, Transport and Tourism),
#' and processed data must say that they were processed.
#'
#' @param year Reference year (school year). See [school_files()] for the
#'   available years. The release of 2013 is left out, as it may not be used
#'   commercially.
#'
#' @return An `sf` tibble with one row per site:
#'
#'   * `year`, `release`: The reference year and the year of its release,
#'     which is `year`.
#'   * `city_code`: 行政区域コード (P29_001) of the municipality, as published:
#'     designated cities are whole cities (for example `"14100"`) in 2021 and
#'     wards in 2023.
#'   * `school_code`: 学校コード (P29_002), as published.
#'   * `school_type_code`: 学校分類 (P29_003): `"16001"` 小学校, `"16002"`
#'     中学校, `"16003"` 中等教育学校, `"16004"` 高等学校, `"16005"`
#'     高等専門学校, `"16006"` 短期大学, `"16007"` 大学, `"16011"` 幼稚園,
#'     `"16012"` 特別支援学校, `"16013"` 幼保連携型認定こども園, `"16014"`
#'     義務教育学校, `"16015"` 各種学校, `"16016"` 専修学校.
#'   * `school_name`, `address`: 名称 and 所在地, as published. The address
#'     leaves out the municipality in 2021 and includes the prefecture and the
#'     municipality in 2023.
#'   * `administrator_code`: 管理者コード (P29_006): `"1"` national, `"2"`
#'     prefectural, `"3"` municipal, `"4"` private, `"0"` other.
#'   * `closure_code`: 休校区分 (P29_007): `"0"` not surveyed, `"1"` open,
#'     `"2"` closed, as surveyed for national and public schools up to high
#'     schools. `"9"` is published but not in the code list.
#'   * `campus_code`, `campus_note`: キャンパスコード (`"00"` none, `"01"` the
#'     main campus, and `"02"` onward the others) and 学校名備考, published from
#'     2023 and `NA` before.
#'   * `geometry`: The school as a point, in JGD2011 (EPSG:6668).
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 学校データ (P29):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P29-2023.html>. See
#'   [data_sources()] for the terms of use.
#'
#' @seealso [school_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' school_get(2023)
#'
#' @export
school_get <- function(year) {
  check_school_year(year)
  inform_terms("school_get")
  school_get_archive(year)
}

# nocov start
school_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = school_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "school"
  )
}
# nocov end

check_school_year <- function(year, call = rlang::caller_env()) {
  rlang::check_required(year, call = call)
  check_number_whole(year, call = call)
  years <- school_files()$year
  if (!year %in% years) {
    cli::cli_abort(
      c(
        "{.arg year} must be a year with schools.",
        i = "Available years: {years}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

#' Files of the schools
#'
#' `school_files()` lists the file of each year of [school_get()]: the national
#' release of 学校 (P29) in [ksjdata::ksj_available], its layer, the EPSG code
#' of its coordinate reference system, the number of schools, and its URL. It
#' is used by the bundled pipeline.
#'
#' @returns A tibble with columns `year`, `file_name`, `layer`, `epsg`,
#'   `n_schools`, and `url`.
#' @keywords internal
#' @export
#' @examples
#' school_files()
school_files <- function() {
  path <- system.file(
    "tarchives",
    "school",
    "files.csv",
    package = "locationchoicedatajp"
  )
  files <- utils::read.csv(
    path,
    colClasses = c(year = "integer", epsg = "integer", n_schools = "integer"),
    encoding = "UTF-8"
  )
  ksj <- ksjdata::ksj_available
  files$url <- ksj$url[match(files$file_name, ksj$file_name)]
  tibble::as_tibble(files)
}

#' Name of the target of a year of schools
#'
#' `school_target_name()` gives the name of the target of a year in the bundled
#' pipeline: `2023` becomes `school_2023`.
#'
#' @param year Years: values of `year` in [school_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' school_target_name(2023)
school_target_name <- function(year) {
  paste0("school_", year)
}

#' Target of schools
#'
#' `school_target()` and `school_target_raw()` declare a target of a 'targets'
#' pipeline whose value is `school_get(year)`. The target is rerun when `year`,
#' the URL of the file of that year, or the installed version of
#' locationchoicedatajp change.
#'
#' @param name Name of the target: a symbol for `school_target()`, a string for
#'   `school_target_raw()`.
#' @inheritParams school_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' school_target(schools_2023, 2023)
school_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  school_target_raw(name = name, year = year, ...)
}

#' @rdname school_target
#' @export
school_target_raw <- function(name, year, ...) {
  check_string(name)
  check_school_year(year)
  files <- school_files()

  command <- rlang::call2(
    "school_get",
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
