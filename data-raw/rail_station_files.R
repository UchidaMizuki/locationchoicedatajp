# Lists the files of the railway stations of National Land Numerical
# Information (N02, 鉄道) and writes them to
# `inst/tarchives/rail-station/files.csv`: the layer of the stations in each
# release, the EPSG code of its coordinate reference system, and the number of
# stations. The release of 2005 holds two versions of its layers, and is left
# out. Review the diff of the CSV before committing it. Needs the network.

library(dplyr)

rail_station_find_layer <- function(file_name, year) {
  env <- asNamespace("ksjdata")
  layers <- env$ksj_read_target(env$ksj_find_file(file_name))
  layer <- grep("_Station$", names(layers), value = TRUE)
  stopifnot(length(layer) == 1)
  data <- layers[[layer]]
  stopifnot(
    all(
      c("N02_001", "N02_002", "N02_003", "N02_004", "N02_005") %in% names(data)
    ),
    all(sf::st_geometry_type(data) == "LINESTRING")
  )
  # Files without a `.prj` file are in the datum of the catalog (世界測地系),
  # set to JGD2000 as for the other datasets.
  epsg <- sf::st_crs(data)$epsg
  if (is.na(sf::st_crs(data))) {
    epsg <- 4612L
  }
  tibble::tibble(
    year = year,
    file_name = file_name,
    layer = layer,
    epsg = epsg,
    n_stations = nrow(data)
  )
}

files <- ksjdata::ksj_available |>
  filter(dataset_code == "N02", year >= 2006) |>
  arrange(year)
stations <- purrr::map2(files$file_name, files$year, rail_station_find_layer) |>
  bind_rows()
print(stations, n = Inf)
readr::write_csv(stations, "inst/tarchives/rail-station/files.csv")
