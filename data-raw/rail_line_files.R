# Lists the files of the railway lines of National Land Numerical Information
# (N02, 鉄道) and writes them to `inst/tarchives/rail-line/files.csv`: the
# layer of the sections of lines in each release, the EPSG code of its
# coordinate reference system, and the number of sections. The releases are
# those of the stations (`rail_station_files()`). Review the diff of the CSV
# before committing it. Needs the network.

library(dplyr)

rail_line_find_layer <- function(file_name, year) {
  env <- asNamespace("ksjdata")
  layers <- env$ksj_read_target(env$ksj_find_file(file_name))
  layer <- grep("_RailroadSection$", names(layers), value = TRUE)
  stopifnot(length(layer) == 1)
  data <- layers[[layer]]
  stopifnot(
    all(c("N02_001", "N02_002", "N02_003", "N02_004") %in% names(data)),
    all(sf::st_geometry_type(data) %in% c("LINESTRING", "MULTILINESTRING"))
  )
  # Files without a `.prj` file are in the datum of the catalog (世界測地系),
  # set to JGD2000 as for the stations.
  epsg <- sf::st_crs(data)$epsg
  if (is.na(sf::st_crs(data))) {
    epsg <- 4612L
  }
  tibble::tibble(
    year = year,
    file_name = file_name,
    layer = layer,
    epsg = epsg,
    n_sections = nrow(data)
  )
}

files <- locationchoicedatajp::rail_station_files()
sections <- purrr::map2(files$file_name, files$year, rail_line_find_layer) |>
  bind_rows()
print(sections, n = Inf)
readr::write_csv(sections, "inst/tarchives/rail-line/files.csv")
