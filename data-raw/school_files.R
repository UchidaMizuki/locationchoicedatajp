# Lists the files of the schools of National Land Numerical Information (P29,
# 学校) and writes them to `inst/tarchives/school/files.csv`: the national file
# of each release, its layer, the EPSG code of its coordinate reference system,
# and the number of schools. The release of 2013 may not be used commercially
# (非商用) and is left out. Review the diff of the CSV before committing it.
# Needs the network.

library(dplyr)

school_find_layer <- function(file_name, year) {
  env <- asNamespace("ksjdata")
  layers <- env$ksj_read_target(env$ksj_find_file(file_name))
  stopifnot(length(layers) == 1)
  data <- layers[[1]]
  stopifnot(
    all(sprintf("P29_%03d", 1:7) %in% names(data)),
    all(sf::st_geometry_type(data) == "POINT")
  )
  tibble::tibble(
    year = year,
    file_name = file_name,
    layer = names(layers),
    epsg = sf::st_crs(data)$epsg,
    n_schools = nrow(data)
  )
}

files <- ksjdata::ksj_available |>
  filter(dataset_code == "P29", area_name == "全国", year >= 2021) |>
  arrange(year)
schools <- purrr::map2(files$file_name, files$year, school_find_layer) |>
  bind_rows()
print(schools, n = Inf)
readr::write_csv(schools, "inst/tarchives/school/files.csv")
