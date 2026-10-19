#' Get commuting flows of the Population Census
#'
#' Returns the flows of residents by place of work or school (従業地・通学地)
#' between municipalities, from the Population Census, one row per origin,
#' destination, place, and sex, as published. The first call for a year and
#' purpose downloads the table from the e-Stat API and builds it, which is then
#' cached. The download needs an e-Stat API key in the environment variable
#' `ESTAT_API_KEY` (see the jpstat package).
#'
#' Flows within the municipality of residence are split into those working at
#' home (`place_code` `011`) and outside the home (`012`), so that models can
#' keep or drop work at home. Flows to unknown places are kept, without a
#' destination. Zero flows between municipalities are kept, so that every
#' origin has a row for every destination.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (the Population Census by the
#' Statistics Bureau of Japan, from e-Stat), and processed data must say that
#' they were processed.
#'
#' @param year The year of the census: 2020. Earlier censuses publish their
#'   flows in other layouts, and are planned.
#' @param purpose The purpose of the trip: `"work"` for employed persons aged
#'   15 and over (15歳以上就業者) or `"school"` for students aged 15 and over
#'   (15歳以上通学者). There is no default, as the purpose is a choice of the
#'   model.
#'
#' @return A tibble with one row per origin, destination, place, and sex:
#'
#'   * `year`: The year of the census (integer), as of October 1.
#'   * `release`: The year of the release the values are taken from (integer).
#'     It is `year`.
#'   * `origin_city_code`: Five-digit code of the municipality of residence, as
#'     published for that year. Designated cities are split into wards.
#'   * `destination_city_code`: Five-digit code of the municipality of work or
#'     school, or `NA` if it is unknown or abroad.
#'   * `place_code`: The place of work or school (従業地・通学地), as
#'     published: `011` at home (自宅で従業), `012` outside the home in the
#'     municipality of residence (自宅外の自市区町村で従業・通学), `02` in
#'     another municipality (他市区町村で従業・通学), `024` in a municipality
#'     that is unknown or abroad (従業・通学市区町村「不詳・外国」), and `03`
#'     unknown (従業地・通学地「不詳」).
#'   * `sex_code`: `1` male and `2` female, as published.
#'   * `flow`: The number of persons (integer).
#'
#'   The flows of each municipality of residence sum to its published number
#'   of employed persons or students.
#'
#' @source Statistics Bureau of Japan, Population Census of 2020, table
#'   0003454524 (男女，就業・通学，従業地・通学地別就業者・通学者数) on e-Stat:
#'   <https://www.e-stat.go.jp/dbview?sid=0003454524>. The terms of use of
#'   e-Stat, based on the Standard Terms of Use of the Government of Japan
#'   (Version 2.0) and compatible with CC BY 4.0, are on
#'   <https://www.e-stat.go.jp/terms-of-use>.
#'
#' @seealso [census_commuting_target()] to declare the table as a target, and
#'   [grid_city_get()] to link municipalities to grid squares.
#'
#' @examplesIf interactive() && nzchar(Sys.getenv("ESTAT_API_KEY"))
#' flows <- census_commuting_get(2020, "work")
#'
#' # Flows outside the home, summed over sex
#' flows |>
#'   dplyr::filter(place_code != "011", !is.na(destination_city_code)) |>
#'   dplyr::summarise(
#'     flow = sum(flow),
#'     .by = c(origin_city_code, destination_city_code)
#'   )
#'
#' @export
census_commuting_get <- function(year, purpose) {
  table <- check_census_commuting_table(year, purpose)
  census_commuting_inform_terms()
  data <- census_commuting_get_archive(table$year, table$purpose)
  dplyr::mutate(data, year = table$year, release = table$year, .before = 1)
}

# nocov start
census_commuting_get_archive <- function(year, purpose) {
  tarchives::tar_get_archive_raw(
    name = census_commuting_target_name(year, purpose),
    package = "locationchoicedatajp",
    pipeline = "census-commuting"
  )
}
# nocov end

check_census_commuting_table <- function(
  year,
  purpose,
  call = rlang::caller_env()
) {
  rlang::check_required(year, call = call)
  rlang::check_required(purpose, call = call)
  check_number_whole(year, call = call)
  purpose <- rlang::arg_match(purpose, c("work", "school"), error_call = call)
  tables <- census_commuting_tables()
  table <- tables[tables$year == year & tables$purpose == purpose, ]
  if (nrow(table) != 1) {
    cli::cli_abort(
      c(
        "There are no commuting flows of {year}.",
        i = "Available years: {unique(tables$year)}."
      ),
      class = "locationchoicedatajp_error_year",
      call = call
    )
  }
  table
}

census_commuting_inform_terms <- function() {
  cli::cli_inform(
    c(
      "Terms of use of the Population Census: the terms of use of e-Stat, based on the Standard Terms of Use of the Government of Japan (Version 2.0) and compatible with CC BY 4.0.",
      i = "{.url https://www.e-stat.go.jp/terms-of-use}"
    ),
    .frequency = "once",
    .frequency_id = "locationchoicedatajp_terms_census"
  )
}

#' Tables of the commuting flows of the Population Census
#'
#' `census_commuting_tables()` lists the tables of [census_commuting_get()] on
#' e-Stat: one row per year and purpose, with the identifier of the table
#' (`stats_data_id`) and the code and name of its item (就業・通学). It is used
#' by the bundled pipeline.
#'
#' @returns A tibble with columns `year`, `purpose`, `stats_data_id`,
#'   `item_code`, and `item_name`.
#' @keywords internal
#' @export
#' @examples
#' census_commuting_tables()
census_commuting_tables <- function() {
  path <- system.file(
    "tarchives",
    "census-commuting",
    "tables.csv",
    package = "locationchoicedatajp"
  )
  data <- utils::read.csv(path, colClasses = "character", encoding = "UTF-8")
  data$year <- as.integer(data$year)
  tibble::as_tibble(data)
}

#' Name of the target of commuting flows
#'
#' `census_commuting_target_name()` gives the name of the target of a year and
#' purpose in the bundled pipeline: `2020` and `"work"` become
#' `census_commuting_2020_work`. It is used by the pipeline and by
#' [census_commuting_get()].
#'
#' @param year,purpose Years and purposes: values of [census_commuting_tables()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' census_commuting_target_name(2020, "work")
census_commuting_target_name <- function(year, purpose) {
  paste0("census_commuting_", year, "_", purpose)
}
