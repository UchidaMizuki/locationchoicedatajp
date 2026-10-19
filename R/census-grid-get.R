#' Get grid square statistics of the Population Census
#'
#' Returns a table of the grid square statistics (地域メッシュ統計) of the
#' Population Census, one row per grid square with residents, as published.
#' The first call for a table downloads its files from e-Stat (by primary grid
#' square) and builds it, which is then cached.
#'
#' The census of each year is its own release. Grid squares have fixed
#' boundaries, so squares of different years compare directly. Squares without
#' residents have no row.
#'
#' Small squares are suppressed (秘匿), except for the population by sex and
#' the number of households: their other values are `NA`, and they are added to
#' another square (`merged_into_grid_code`), whose values then include them.
#'
#' The first time in a session, the terms of use are shown. Published or
#' processed data must credit the source (the grid square statistics of the
#' Population Census by the Statistics Bureau of Japan), and processed data
#' must say that they were processed.
#'
#' @param year The year of the census: 2010, 2015, or 2020.
#' @param grid_size The size of the grid squares: one of [grid_sizes()]. There
#'   is no default, as the size is a choice of the model.
#' @param table_code The number of the table (統計表), such as `"001-01"`. See
#'   [census_grid_tables()] for the tables of each year and size.
#'
#' @return A tibble with one row per grid square:
#'
#'   * `year`: The year of the census (integer), as of October 1.
#'   * `release`: The year of the release the values are taken from (integer).
#'     It is `year`.
#'   * `grid_code`: The code of the grid square (see [grid_city_get()]).
#'   * `suppression_code`: The suppression of the square (秘匿処理), as
#'     published: `0` not suppressed, `1` a square that includes suppressed
#'     squares (合算地域), and `2` a suppressed square (秘匿地域). `NA` for
#'     2010, whose tables have no suppression.
#'   * `merged_into_grid_code`: For a suppressed square, the square that
#'     includes its values (合算先), otherwise `NA`.
#'   * One integer column per item, named by its code, as published (for
#'     example `T001141001` for 人口（総数）). Suppressed values are `NA`. See
#'     [census_grid_items()] for the names and units of the items.
#'
#' @source Statistics Bureau of Japan, grid square statistics of the
#'   Population Census (国勢調査に関する地域メッシュ統計), from e-Stat:
#'   <https://www.e-stat.go.jp/gis>. The terms of use of e-Stat, based on the
#'   Standard Terms of Use of the Government of Japan (Version 2.0) and
#'   compatible with CC BY 4.0, are on <https://www.e-stat.go.jp/terms-of-use>.
#'
#' @seealso [census_grid_target()] to declare the table as a target.
#'
#' @examplesIf interactive()
#' census_grid_get(2020, "500m", "001-01")
#'
#' @export
census_grid_get <- function(year, grid_size, table_code) {
  table <- check_census_grid_table(year, grid_size, table_code)
  census_grid_inform_terms()
  data <- census_grid_get_archive(table$stats_id)
  dplyr::mutate(data, year = table$year, release = table$year, .before = 1)
}

# nocov start
census_grid_get_archive <- function(stats_id) {
  tarchives::tar_get_archive_raw(
    name = census_grid_target_name(stats_id),
    package = "locationchoicedatajp",
    pipeline = "census-grid"
  )
}
# nocov end

# The row of `census_grid_tables()` of the arguments.
check_census_grid_table <- function(
  year,
  grid_size,
  table_code,
  call = rlang::caller_env()
) {
  rlang::check_required(year, call = call)
  rlang::check_required(table_code, call = call)
  check_number_whole(year, call = call)
  grid_size <- check_grid_size(grid_size, call = call)
  check_string(table_code, call = call)
  tables <- census_grid_tables()
  table <- tables[
    tables$year == year &
      tables$grid_size == grid_size &
      tables$table_code == table_code,
  ]
  if (nrow(table) != 1) {
    cli::cli_abort(
      c(
        "There is no table {.val {table_code}} of {year} at {grid_size}.",
        i = "See {.fn census_grid_tables} for the tables."
      ),
      class = "locationchoicedatajp_error_table",
      call = call
    )
  }
  table
}

census_grid_inform_terms <- function() {
  cli::cli_inform(
    c(
      "Terms of use of the grid square statistics of the Population Census: the terms of use of e-Stat, based on the Standard Terms of Use of the Government of Japan (Version 2.0) and compatible with CC BY 4.0.",
      i = "{.url https://www.e-stat.go.jp/terms-of-use}"
    ),
    .frequency = "once",
    .frequency_id = "locationchoicedatajp_terms_census_grid"
  )
}

#' Tables of the grid square statistics of the Population Census
#'
#' `census_grid_tables()` lists the tables of [census_grid_get()], and
#' `census_grid_items()` their items, as given in the definitions of the tables
#' on e-Stat. The tables of 2010 have only the population by sex and the number
#' of households, and its 250 m table covers only 東京都特別区部, designated
#' cities, and prefectural capitals.
#'
#' @returns `census_grid_tables()` returns a tibble with one row per table:
#'   `stats_id` (the identifier of the table on e-Stat), `year`, `survey_date`,
#'   `grid_size`, `table_code`, `table_name`, and `collection_name`, as
#'   published.
#'
#'   `census_grid_items()` returns a tibble with one row per item of each table:
#'   `stats_id`, `item_code` (the name of its column in [census_grid_get()]),
#'   `level` (the depth of the item in the table), `item_name`, and `unit`, as
#'   published.
#' @export
#' @examples
#' census_grid_tables()
#'
#' # The items of the 500 m table of 2020
#' items <- census_grid_items()
#' items[items$stats_id == "T001141", ]
census_grid_tables <- function() {
  data <- census_grid_read_csv("tables.csv")
  data$year <- as.integer(data$year)
  data$survey_date <- as.Date(data$survey_date)
  data
}

#' @rdname census_grid_tables
#' @export
census_grid_items <- function() {
  data <- census_grid_read_csv("items.csv")
  data$level <- as.integer(data$level)
  data
}

#' Primary grid squares of the census grid statistics
#'
#' `census_grid_primary_grids()` lists the primary grid squares (80 km) with
#' land, the units in which the tables of [census_grid_get()] are downloaded.
#' It is used by the bundled pipeline.
#'
#' @returns A character vector of four-digit codes.
#' @keywords internal
#' @export
#' @examples
#' census_grid_primary_grids()
census_grid_primary_grids <- function() {
  census_grid_read_csv("primary_grids.csv")$primary_grid_code
}

census_grid_read_csv <- function(file) {
  path <- system.file(
    "tarchives",
    "census-grid",
    file,
    package = "locationchoicedatajp"
  )
  data <- utils::read.csv(path, colClasses = "character", encoding = "UTF-8")
  tibble::as_tibble(data)
}

#' Name of the target of a census grid table
#'
#' `census_grid_target_name()` gives the name of the target of a table of
#' [census_grid_tables()] in the bundled pipeline: `T001141` becomes
#' `census_grid_t001141`. It is used by the pipeline and by
#' [census_grid_get()].
#'
#' @param stats_id Identifiers of tables: values of `stats_id` in
#'   [census_grid_tables()].
#' @returns A character vector of target names.
#' @keywords internal
#' @export
#' @examples
#' census_grid_target_name("T001141")
census_grid_target_name <- function(stats_id) {
  paste0("census_grid_", tolower(stats_id))
}
