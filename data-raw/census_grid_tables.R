# Writes the catalog of the grid square statistics (地域メッシュ統計) of the
# Population Census to `inst/tarchives/census-grid/`:
#
# * `tables.csv`: one row per table, read from its definition on e-Stat.
# * `items.csv`: one row per item of each table, from the same definition.
# * `primary_grids.csv`: the primary grid squares (80 km) with land, the units
#   in which the tables are downloaded.
#
# The tables are listed by hand below, as e-Stat lists them only in a page built
# by JavaScript. Add the tables of a new census here. Review the diff of the CSV
# files before committing them. Needs the network, and the crosswalk of
# `grid_city_get()` for 2020 (built on first use).

library(dplyr)

# Tables of 地域メッシュ統計 (00200511) from the Population Census, at 1 km,
# 500 m, and 250 m. 2010 has only population by sex and households, and its
# 250 m table covers only 東京都特別区部, designated cities, and prefectural
# capitals.
stats_ids <- c(
  # 2010
  "T000608",
  "T000609",
  "T000649",
  # 2015
  "T000846",
  "T000847",
  "T000876",
  "T000877",
  "T000879",
  "T000881",
  "T000878",
  "T000880",
  "T000882",
  # 2020
  "T001140",
  "T001141",
  "T001142",
  "T001143",
  "T001144",
  "T001145"
)

definition_url <- function(stats_id) {
  paste0(
    "https://www.e-stat.go.jp/help/data-definition-information/downloaddata/",
    stats_id,
    ".pdf"
  )
}

# Lines of the definition of a table, with runs of spaces as `|`.
read_definition <- function(stats_id) {
  path <- tempfile(fileext = ".pdf")
  on.exit(unlink(path))
  curl::curl_download(definition_url(stats_id), path, quiet = TRUE)
  Sys.sleep(1)
  text <- paste(pdftools::pdf_text(path), collapse = "\n")
  lines <- stringr::str_replace_all(
    stringr::str_trim(stringr::str_split_1(text, "\n")),
    "\\s{2,}",
    "|"
  )
  lines[nzchar(lines)]
}

field <- function(lines, key) {
  line <- lines[stringr::str_starts(lines, paste0(key, "\\|"))][[1]]
  stringr::str_split_1(line, "\\|")[-1]
}

grid_size_of <- function(unit) {
  sizes <- c(
    "基準地域メッシュ" = "1km",
    "1kmメッシュ" = "1km",
    "500mメッシュ" = "500m",
    "250mメッシュ" = "250m"
  )
  unname(sizes[stringi::stri_trans_nfkc(unit)])
}

read_table <- function(stats_id) {
  lines <- read_definition(stats_id)
  table <- field(lines, "統計表名")
  date <- field(lines, "調査日")[[1]]
  items <- lines[stringr::str_starts(lines, paste0(stats_id, "[0-9]{3}\\|"))]
  items <- stringr::str_split(items, "\\|")
  # Headings have only a code, a level, and a name; items also have a unit and
  # the numbers of their table.
  items <- items[lengths(items) > 3]
  stopifnot(all(lengths(items) == 6))

  list(
    table = tibble::tibble(
      stats_id = stats_id,
      year = as.integer(substr(date, 1, 4)),
      survey_date = as.Date(date, format = "%Y%m%d"),
      grid_size = grid_size_of(field(lines, "集計単位")[[1]]),
      table_code = table[[1]],
      table_name = table[[2]],
      collection_name = field(lines, "集計表名")[[1]]
    ),
    items = tibble::tibble(
      stats_id = stats_id,
      item_code = purrr::map_chr(items, 1),
      level = as.integer(purrr::map_chr(items, 2)),
      item_name = purrr::map_chr(items, 3),
      unit = purrr::map_chr(items, 4)
    )
  )
}

definitions <- purrr::map(stats_ids, read_table)
tables <- purrr::map(definitions, "table") |> bind_rows()
items <- purrr::map(definitions, "items") |> bind_rows()

stopifnot(
  !anyNA(tables$grid_size),
  all(stringr::str_detect(tables$collection_name, "国勢調査")),
  !anyDuplicated(tables[c("year", "grid_size", "table_code")])
)
print(tables, n = Inf)
print(count(items, stats_id), n = Inf)

# Primary grid squares with land in the crosswalk of 2020. Census squares have
# residents, so they lie on land.
primary_grids <- locationchoicedatajp::grid_city_get("2020-10-01", "1km") |>
  distinct(primary_grid_code = substr(grid_code, 1, 4)) |>
  arrange(primary_grid_code)
print(nrow(primary_grids))

dir <- "inst/tarchives/census-grid"
fs::dir_create(dir)
readr::write_csv(tables, fs::path(dir, "tables.csv"))
readr::write_csv(items, fs::path(dir, "items.csv"))
readr::write_csv(primary_grids, fs::path(dir, "primary_grids.csv"))
