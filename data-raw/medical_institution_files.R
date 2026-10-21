# Lists the files of the medical institutions of National Land Numerical
# Information (P04, 医療機関) and writes them to
# `inst/tarchives/medical-institution/files.csv`: the national file of each
# release, its layer, the EPSG code of its coordinate reference system, and the
# number of institutions. The releases of 2010 and 2014 may not be used
# commercially (非商用) and are left out. Review the diff of the CSV before
# committing it. Needs the network.

library(dplyr)

medical_institution_find_layer <- function(file_name, year) {
  env <- asNamespace("ksjdata")
  layers <- env$ksj_read_target(env$ksj_find_file(file_name))
  stopifnot(length(layers) == 1)
  data <- layers[[1]]
  stopifnot(
    all(sprintf("P04_%03d", 1:10) %in% names(data)),
    all(sf::st_geometry_type(data) == "POINT")
  )
  tibble::tibble(
    year = year,
    file_name = file_name,
    layer = names(layers),
    epsg = sf::st_crs(data)$epsg,
    n_institutions = nrow(data)
  )
}

files <- ksjdata::ksj_available |>
  filter(dataset_code == "P04", area_name == "全国", year >= 2020) |>
  arrange(year)
institutions <- purrr::map2(
  files$file_name,
  files$year,
  medical_institution_find_layer
) |>
  bind_rows()
print(institutions, n = Inf)
readr::write_csv(
  institutions,
  "inst/tarchives/medical-institution/files.csv"
)
