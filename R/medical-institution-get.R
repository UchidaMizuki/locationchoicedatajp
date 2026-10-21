#' Get medical institutions
#'
#' Returns the medical institutions of National Land Numerical Information
#' (医療機関, P04) in a year, one row per institution, as published. The first
#' call for a year downloads the file of that year's release (via ksjdata) and
#' builds the table, which is then cached.
#'
#' The institutions are the hospitals, clinics, and dental clinics of the
#' Medical Care Act, including dormant ones and those inside companies, but not
#' those that only visit.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 医療機関データ, by the Ministry of Land, Infrastructure, Transport and
#' Tourism), and processed data must say that they were processed.
#'
#' @param year Reference year (fiscal year). See [medical_institution_files()]
#'   for the available years. The releases of 2010 and 2014 are left out, as
#'   they may not be used commercially.
#'
#' @return An `sf` tibble with one row per institution:
#'
#'   * `year`, `release`: The reference year and the year of its release,
#'     which is `year`.
#'   * `institution_type_code`: 医療機関分類 (P04_001): `"1"` hospital (病院),
#'     `"2"` clinic (診療所), `"3"` dental clinic (歯科診療所).
#'   * `institution_name`, `address`: 施設名称 and 所在地, as published.
#'   * `specialties_1`, `specialties_2`, `specialties_3`: 診療科目 (P04_004 to
#'     P04_006), as published: the specialties separated by full-width spaces,
#'     continued in the second and third columns when they are too long for
#'     the first.
#'   * `founder_type_code`: 開設者分類 (P04_007) of hospitals: `"1"` national,
#'     `"2"` public, `"3"` social insurance organizations, `"4"` medical
#'     corporations, `"5"` individuals, `"6"` other, and `"9"` not classified
#'     (clinics and dental clinics).
#'   * `beds`: 病床数 (P04_008), the number of beds, as published.
#'   * `emergency_code`: 救急告示病院 (P04_009): `"1"` designated, `"9"` not.
#'   * `disaster_base_code`: 災害拠点病院 (P04_010): `"1"` core, `"2"`
#'     regional, `"9"` not designated.
#'   * `geometry`: The institution as a point, in JGD2011 (EPSG:6668).
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 医療機関データ (P04):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P04-2020.html>. See
#'   [data_sources()] for the terms of use.
#'
#' @seealso [medical_institution_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' medical_institution_get(2020)
#'
#' @export
medical_institution_get <- function(year) {
  check_medical_institution_year(year)
  inform_terms("medical_institution_get")
  medical_institution_get_archive(year)
}

# nocov start
medical_institution_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = medical_institution_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "medical-institution"
  )
}
# nocov end

check_medical_institution_year <- function(year, call = rlang::caller_env()) {
  rlang::check_required(year, call = call)
  check_number_whole(year, call = call)
  years <- medical_institution_files()$year
  if (!year %in% years) {
    cli::cli_abort(
      c(
        "{.arg year} must be a year with medical institutions.",
        i = "Available years: {years}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

#' Files of the medical institutions
#'
#' `medical_institution_files()` lists the file of each year of
#' [medical_institution_get()]: the national release of 医療機関 (P04) in
#' [ksjdata::ksj_available], its layer, the EPSG code of its coordinate
#' reference system, the number of institutions, and its URL. It is used by the
#' bundled pipeline.
#'
#' @returns A tibble with columns `year`, `file_name`, `layer`, `epsg`,
#'   `n_institutions`, and `url`.
#' @keywords internal
#' @export
#' @examples
#' medical_institution_files()
medical_institution_files <- function() {
  path <- system.file(
    "tarchives",
    "medical-institution",
    "files.csv",
    package = "locationchoicedatajp"
  )
  files <- utils::read.csv(
    path,
    colClasses = c(
      year = "integer",
      epsg = "integer",
      n_institutions = "integer"
    ),
    encoding = "UTF-8"
  )
  ksj <- ksjdata::ksj_available
  files$url <- ksj$url[match(files$file_name, ksj$file_name)]
  tibble::as_tibble(files)
}

#' Name of the target of a year of medical institutions
#'
#' `medical_institution_target_name()` gives the name of the target of a year
#' in the bundled pipeline: `2020` becomes `medical_institution_2020`.
#'
#' @param year Years: values of `year` in [medical_institution_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' medical_institution_target_name(2020)
medical_institution_target_name <- function(year) {
  paste0("medical_institution_", year)
}

#' Target of medical institutions
#'
#' `medical_institution_target()` and `medical_institution_target_raw()`
#' declare a target of a 'targets' pipeline whose value is
#' `medical_institution_get(year)`. The target is rerun when `year`, the URL of
#' the file of that year, or the installed version of locationchoicedatajp
#' change.
#'
#' @param name Name of the target: a symbol for `medical_institution_target()`,
#'   a string for `medical_institution_target_raw()`.
#' @inheritParams medical_institution_get
#' @param ... Other arguments passed to [targets::tar_target_raw()].
#' @returns A target object.
#' @export
#' @examples
#' medical_institution_target(institutions_2020, 2020)
medical_institution_target <- function(name, year, ...) {
  name <- targets::tar_deparse_language(substitute(name))
  medical_institution_target_raw(name = name, year = year, ...)
}

#' @rdname medical_institution_target
#' @export
medical_institution_target_raw <- function(name, year, ...) {
  check_string(name)
  check_medical_institution_year(year)
  files <- medical_institution_files()

  command <- rlang::call2(
    "medical_institution_get",
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
