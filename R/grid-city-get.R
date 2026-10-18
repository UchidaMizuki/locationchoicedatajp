#' Get the crosswalk of grid squares to municipalities
#'
#' Returns, for each grid square, the area of it in each municipality and its
#' share, from the administrative boundaries (行政区域, N03 of National Land
#' Numerical Information) in force on a date. It links tables on grid squares
#' to tables on municipalities, such as commuting flows. The first call for a
#' release downloads its files (via ksjdata, about 370 MB) and builds the
#' table, which takes about 45 minutes; it is then cached, and later calls take
#' about a second.
#'
#' Grid squares straddle municipal boundaries, so a square can have several
#' rows. Areas are of land within the administrative boundaries, so squares
#' on the coast or at the border of the country count only their land. Areas
#' are computed on the GRS80 ellipsoid (in an Albers equal-area projection).
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 行政区域データ, by the Ministry of Land, Infrastructure, Transport and
#' Tourism), and processed data must say that they were processed.
#'
#' @param date The date of the boundaries: a `Date` or a string such as
#'   `"2020-10-01"`. The release in force on that date is used, which is the
#'   latest release with `boundary_date` on or before it. Use the reference
#'   date of the table to link, for example October 1 for the Population
#'   Census and January 1 for 地価公示. See [grid_city_files()] for the
#'   releases.
#' @param grid_size The size of the grid squares: `"500m"` (the default) or
#'   `"1km"`. Areas of 1 km squares are the sums of the areas of their four 500
#'   m squares. Both are built and cached for a release on the first call.
#'
#' @return A tibble with one row per grid square and municipality:
#'
#'   * `boundary_date`: The date of the boundaries of the release (`Date`).
#'   * `release`: The year of the release in National Land Numerical
#'     Information (integer).
#'   * `grid_code`: The code of the grid square (地域メッシュ・コード), nine
#'     digits for 500 m and eight digits for 1 km.
#'   * `city_code`: Five-digit municipality code, as published in the release.
#'     Designated cities are split into wards. Land whose municipality is
#'     undetermined (所属未定地) is `NA`.
#'   * `area_m2`: The land area of the grid square in the municipality, in
#'     square meters.
#'   * `share`: The share of the land area of the grid square in the
#'     municipality. The shares of a grid square sum to one.
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 行政区域データ (N03):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2026.html>.
#'
#' @seealso [grid_code()] to give points the code of their grid square.
#'
#' @examplesIf interactive()
#' grid_city_get("2020-10-01")
#'
#' @export
grid_city_get <- function(date, grid_size = c("500m", "1km")) {
  date <- check_boundary_date(date)
  grid_size <- rlang::arg_match(grid_size)
  files <- grid_city_files()
  boundary_date <- grid_city_release_date(date, files)
  release <- files$release[files$boundary_date == boundary_date][[1]]
  grid_city_inform_terms()

  data <- grid_city_get_archive(boundary_date, grid_size)
  dplyr::mutate(
    data,
    boundary_date = boundary_date,
    release = release,
    .before = 1
  )
}

grid_city_get_archive <- function(boundary_date, grid_size) {
  tarchives::tar_get_archive_raw(
    name = grid_city_release_target_name(boundary_date, grid_size),
    package = "locationchoicedatajp",
    pipeline = "grid-city"
  )
}

check_boundary_date <- function(date, call = rlang::caller_env()) {
  if (rlang::is_string(date)) {
    date <- tryCatch(as.Date(date), error = function(e) NA)
  }
  if (!inherits(date, "Date") || length(date) != 1 || is.na(date)) {
    cli::cli_abort(
      "{.arg date} must be a single date, such as {.val 2020-10-01}.",
      class = "locationchoicedatajp_error_date",
      call = call
    )
  }
  date
}

grid_city_release_date <- function(date, files, call = rlang::caller_env()) {
  dates <- unique(files$boundary_date)
  dates <- dates[dates <= date]
  if (length(dates) == 0) {
    cli::cli_abort(
      c(
        "There are no boundaries in force on {.val {format(date)}}.",
        i = "The first release is of {.val {format(min(files$boundary_date))}}."
      ),
      class = "locationchoicedatajp_error_date",
      call = call
    )
  }
  max(dates)
}

grid_city_inform_terms <- function() {
  files <- ksjdata::ksj_available
  file <- files[files$dataset_code == "N03", ][1, ]
  cli::cli_inform(
    c(
      "Terms of use of {file$dataset_code} ({file$dataset_name}): {file$license_name}",
      i = "{file$license_note}",
      i = "{.url {file$license_url}}"
    ),
    .frequency = "once",
    .frequency_id = "locationchoicedatajp_terms_n03"
  )
}

#' Files of the crosswalk of grid squares to municipalities
#'
#' `grid_city_files()` lists the files of [grid_city_get()]: the files by
#' prefecture of each release of 行政区域 (N03) in [ksjdata::ksj_available]
#' since 2007, with the date of their boundaries, read from the file name. It
#' is used by the bundled pipeline.
#'
#' @returns A tibble with one row per file: `boundary_date`, `release` (the
#'   year of the release), `prefecture_code`, `file_name`, and `url`.
#' @keywords internal
#' @export
#' @examples
#' grid_city_files()
grid_city_files <- function() {
  files <- ksjdata::ksj_available
  files <- files[
    files$dataset_code == "N03" &
      files$year >= 2007 &
      !is.na(files$prefecture_code),
  ]
  # File names give the date as YYMMDD until 2019 and as YYYYMMDD from 2020.
  date <- sub("^N03-([0-9]{6,8})_.*$", "\\1", files$file_name)
  date <- ifelse(nchar(date) == 6, paste0("20", date), date)
  tibble::tibble(
    boundary_date = as.Date(date, format = "%Y%m%d"),
    release = files$year,
    prefecture_code = files$prefecture_code,
    file_name = files$file_name,
    url = files$url
  )[order(date, files$prefecture_code), ]
}

#' Name of the target of a file of the crosswalk
#'
#' `grid_city_target_name()` gives the name of the target of a file of
#' [grid_city_files()] in the bundled pipeline: `N03-20200101_13_GML.zip`
#' becomes `grid_city_20200101_13`. `grid_city_release_target_name()` gives the
#' name of the target that binds the files of a release into grid squares of a
#' size: `2020-01-01` and `"500m"` become `grid_city_20200101_500m`. They are used by the pipeline and by
#' [grid_city_get()].
#'
#' @param file_name Names of files: values of `file_name` in
#'   [grid_city_files()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' grid_city_target_name("N03-20200101_13_GML.zip")
grid_city_target_name <- function(file_name) {
  suffix <- sub("^N03-([0-9]{6,8}_[0-9]{2})_GML\\.zip$", "\\1", file_name)
  paste0("grid_city_", suffix)
}

#' @rdname grid_city_target_name
#' @param boundary_date Dates of the boundaries of releases: values of
#'   `boundary_date` in [grid_city_files()].
#' @inheritParams grid_city_get
#' @export
#' @examples
#' grid_city_release_target_name(as.Date("2020-01-01"), "500m")
grid_city_release_target_name <- function(boundary_date, grid_size) {
  paste0("grid_city_", format(boundary_date, "%Y%m%d"), "_", grid_size)
}
