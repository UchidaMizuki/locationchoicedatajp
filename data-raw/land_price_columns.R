# Finds the columns of the land price files of National Land Numerical
# Information (L01, 地価公示) in each release and writes them to
# `inst/tarchives/land-price/columns.csv`. The layout of the files changes
# between releases, and the attribute table describes only the latest one, so
# the columns are found from their contents and checked here. Review the diff
# of the CSV before committing it. Needs the network.

library(dplyr)

land_price_find_columns <- function(file_name, year) {
  layer <- ksjdata::ksj_get(file_name, col_names = "raw")
  data <- sf::st_drop_geometry(layer)
  # Columns with missing values never match.
  all_match <- function(x, pattern) {
    !anyNA(x) && all(stringr::str_detect(x, pattern))
  }
  is_code <- function(x, pattern) {
    is.character(x) && all_match(x, pattern)
  }
  city <- names(data)[purrr::map_lgl(
    data,
    is_code,
    "^(0[1-9]|[1-4][0-9])[0-9]{3}$"
  )]
  stopifnot(length(city) == 1)

  # The year of the price is in the column before the price, written as a
  # number or as text (`西暦 2013`).
  is_year <- purrr::map_lgl(data, all_match, as.character(year))
  year_column <- names(data)[is_year][[1]]
  price <- names(data)[[match(year_column, names(data)) + 1]]

  # The number of a site (標準地番号) is its use and serial number, after the
  # municipality when the municipality is in the first column.
  if (city == "L01_001") {
    use <- "L01_002"
    serial <- "L01_003"
  } else {
    use <- "L01_001"
    serial <- "L01_002"
  }
  stopifnot(
    is_code(data[[use]], "^0[0-9]{2}$"),
    is_code(data[[serial]], "^[0-9]{3}$"),
    !anyDuplicated(paste(data[[city]], data[[use]], data[[serial]]))
  )

  price_values <- as.numeric(data[[price]])
  stopifnot(!anyNA(price_values), all(price_values > 0))

  # Files without a `.prj` file are in the datum of the catalog (世界測地系),
  # which is JGD2000 for these releases.
  epsg <- sf::st_crs(layer)$epsg
  if (is.na(sf::st_crs(layer))) {
    epsg <- 4612L
  }

  tibble::tibble(
    year = year,
    file_name = file_name,
    city_code = city,
    use_code = use,
    site_number = serial,
    price = price,
    epsg = epsg,
    n_points = nrow(data)
  )
}

files <- ksjdata::ksj_available |>
  filter(dataset_code == "L01", is.na(prefecture_code), area_name == "全国") |>
  arrange(year)

columns <- purrr::map2(files$file_name, files$year, land_price_find_columns) |>
  bind_rows()
print(columns, n = Inf)

readr::write_csv(columns, "inst/tarchives/land-price/columns.csv")
