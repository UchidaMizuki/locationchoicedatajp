#' Get land prices by municipality
#'
#' Returns the official land prices (地価公示) of National Land Numerical
#' Information summarised by municipality and use. The first call for a year
#' downloads the file of that year's release (via ksjdata) and builds the
#' table, which is then cached.
#'
#' Each year is taken from its own release, so a year covers every site that
#' was surveyed in it, and its values do not change when a later release is
#' published.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (National Land Numerical Information,
#' 地価公示データ, by the Ministry of Land, Infrastructure, Transport and
#' Tourism), and processed data must say that they were processed.
#'
#' @param year Reference years, from 2007 to the latest release. See
#'   [land_price_files()] for the available years.
#'
#' @return A tibble with one row per year, municipality, and use:
#'
#'   * `year`: The reference year (integer). Prices are as of January 1.
#'   * `release`: The year of the release the values are taken from (integer).
#'     It is `year`.
#'   * `city_code`: Five-digit municipality code of the site, as published for
#'     that year. Designated cities are split into wards.
#'   * `use_code`: Three-digit use of the site (用途区分), as published. The
#'     codes are those of the code list of the latest release (`000` 住宅地,
#'     `003` 宅地見込地, `005` 商業地, `009` 工業地, `013` 林地) and, until
#'     2012, also `007` and `010`, which are not used from 2013. The files of
#'     2014 to 2016 have no sites of `003` or `013`. Compare uses across these
#'     breaks with care.
#'   * `n_points`: The number of sites.
#'   * `price_median_jpy_per_m2`, `price_mean_jpy_per_m2`: The median and the
#'     mean price of the sites, in yen per square meter. Sites are not
#'     weighted.
#'
#' @source Ministry of Land, Infrastructure, Transport and Tourism, National
#'   Land Numerical Information, 地価公示データ (L01):
#'   <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L01-2026.html>. The
#'   terms of use are on
#'   <https://nlftp.mlit.go.jp/ksj/other/agreement_01.html>.
#'
#' @seealso [land_price_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' land_price_get(2020)
#'
#' # Several years
#' land_price_get(c(2010, 2015, 2020))
#'
#' @export
land_price_get <- function(year) {
  check_land_price_year(year)
  land_price_inform_terms()
  data <- lapply(year, \(year) land_price_get_archive(year))
  vctrs::vec_rbind(!!!data)
}

land_price_get_archive <- function(year) {
  tarchives::tar_get_archive_raw(
    name = land_price_target_name(year),
    package = "locationchoicedatajp",
    pipeline = "land-price"
  )
}

check_land_price_year <- function(year, call = rlang::caller_env()) {
  years <- land_price_files()$year
  if (!is.numeric(year) || length(year) == 0 || !all(year %in% years)) {
    cli::cli_abort(
      c(
        "{.arg year} must be years with land prices.",
        i = "Available years: {min(years)} to {max(years)}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
}

land_price_inform_terms <- function() {
  files <- ksjdata::ksj_available
  file <- files[files$dataset_code == "L01", ][1, ]
  cli::cli_inform(
    c(
      "Terms of use of {file$dataset_code} ({file$dataset_name}): {file$license_name}",
      i = "{file$license_note}",
      i = "{.url {file$license_url}}"
    ),
    .frequency = "once",
    .frequency_id = "locationchoicedatajp_terms_l01"
  )
}

#' Files of the land prices
#'
#' `land_price_files()` lists the file of each year of [land_price_get()]: the
#' nationwide file of that year's release of 地価公示 (L01) in
#' [ksjdata::ksj_available], with the columns that hold the municipality, the
#' use, and the price, and the number of sites. The layout of the files
#' changes between releases, so the columns are listed for each one. It is
#' used by the bundled pipeline.
#'
#' @returns A tibble with one row per year: `year`, `file_name`, the columns
#'   `city_code`, `use_code`, and `price`, `n_points`, and the `url` of the
#'   file.
#' @keywords internal
#' @export
#' @examples
#' land_price_files()
land_price_files <- function() {
  path <- system.file(
    "tarchives",
    "land-price",
    "columns.csv",
    package = "locationchoicedatajp"
  )
  files <- utils::read.csv(
    path,
    colClasses = c(year = "integer", n_points = "integer"),
    encoding = "UTF-8"
  )
  ksj <- ksjdata::ksj_available
  files$url <- ksj$url[match(files$file_name, ksj$file_name)]
  tibble::as_tibble(files)
}

#' Name of the target of a year of land prices
#'
#' `land_price_target_name()` gives the name of the target of a year in the
#' bundled pipeline: `2020` becomes `land_price_2020`. It is used by the
#' pipeline and by [land_price_get()].
#'
#' @param year Reference years.
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' land_price_target_name(2020)
land_price_target_name <- function(year) {
  paste0("land_price_", year)
}
