# Lists the files of the municipal offices and public meeting facilities of
# National Land Numerical Information (P05, 市町村役場等及び公的集会施設) and
# writes them to `inst/tarchives/public-facility/files.csv`: the national file
# of each release, the prefix of its layers (one per prefecture, `<prefix>_01`
# to `<prefix>_47`), the EPSG code of its coordinate reference system, and the
# number of facilities. The release of 2010 may not be used commercially
# (非商用) and is left out. Review the diff of the CSV before committing it.
# Needs the network and ksjdata with the support of nested archives.

library(dplyr)

public_facility_find_layers <- function(file_name, year) {
  env <- asNamespace("ksjdata")
  layers <- env$ksj_read_target(env$ksj_find_file(file_name))
  prefix <- sub("_GML[.]zip$", "", file_name)
  stopifnot(
    identical(names(layers), sprintf("%s_%02d", prefix, 1:47)),
    all(purrr::map_lgl(layers, \(data) {
      identical(names(data), c(sprintf("P05_%03d", 1:4), "geometry"))
    })),
    all(purrr::map_lgl(layers, \(data) {
      all(sf::st_geometry_type(data) == "POINT")
    }))
  )
  epsg <- unique(purrr::map_int(layers, \(data) sf::st_crs(data)$epsg))
  stopifnot(length(epsg) == 1)
  tibble::tibble(
    year = year,
    file_name = file_name,
    layer_prefix = prefix,
    epsg = epsg,
    n_facilities = sum(purrr::map_int(layers, nrow))
  )
}

files <- ksjdata::ksj_available |>
  filter(dataset_code == "P05", area_name == "全国", year >= 2022) |>
  arrange(year)
facilities <- purrr::map2(
  files$file_name,
  files$year,
  public_facility_find_layers
) |>
  bind_rows()
print(facilities, n = Inf)
readr::write_csv(facilities, "inst/tarchives/public-facility/files.csv")
