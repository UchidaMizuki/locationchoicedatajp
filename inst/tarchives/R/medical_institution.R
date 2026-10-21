# Helpers of the medical institutions, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the medical institutions: one per year of
# `medical_institution_files()`. The URL is part of the command, so a replaced
# file rebuilds that year only.
medical_institution_pipeline <- function() {
  files <- locationchoicedatajp::medical_institution_files()
  names <- locationchoicedatajp::medical_institution_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(
      name,
      medical_institution_build(
        year,
        file_name,
        url,
        layer,
        epsg,
        n_institutions
      )
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      layer = files$layer,
      epsg = files$epsg,
      n_institutions = files$n_institutions
    )
  )
}

# Institutions of a year from the file of its release. `url` is unused: it is
# an argument so that the URL is part of the command.
medical_institution_build <- function(
  year,
  file_name,
  url,
  layer,
  epsg,
  n_institutions
) {
  # The terms of use are shown by `medical_institution_get()`, not again by
  # ksjdata in the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  data <- ksjdata::ksj_get(file_name, layer = layer, col_names = "raw")
  medical_institution_check(nrow(data) == n_institutions, "number")
  medical_institution_institutions(data, year, epsg)
}

# Institutions with their columns renamed, as published. Codes stored as
# numbers are kept as character. The specialties are split into three columns
# as published, the second and third holding what does not fit in the first.
medical_institution_institutions <- function(data, year, epsg) {
  institutions <- tibble::tibble(
    year = year,
    release = year,
    institution_type_code = as.character(data$P04_001),
    institution_name = data$P04_002,
    address = data$P04_003,
    specialties_1 = data$P04_004,
    specialties_2 = data$P04_005,
    specialties_3 = data$P04_006,
    founder_type_code = as.character(data$P04_007),
    beds = as.integer(data$P04_008),
    emergency_code = as.character(data$P04_009),
    disaster_base_code = as.character(data$P04_010)
  )
  check <- medical_institution_check
  check(institutions$institution_type_code %in% c("1", "2", "3"), "types")
  check(
    institutions$founder_type_code %in% c("1", "2", "3", "4", "5", "6", "9"),
    "founders"
  )
  check(institutions$emergency_code %in% c("1", "9"), "emergency hospitals")
  check(
    institutions$disaster_base_code %in% c("1", "2", "9"),
    "disaster base hospitals"
  )
  check(institutions$beds >= 0, "beds")
  check(!is.na(institutions$institution_name), "names")

  geometry <- sf::st_geometry(data)
  check(sf::st_crs(geometry)$epsg == epsg, "coordinate systems")
  check(
    sf::st_geometry_type(geometry) == "POINT" & !sf::st_is_empty(geometry),
    "locations"
  )
  sf::st_sf(institutions, geometry = geometry)
}

medical_institution_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the medical institutions are not as expected.", what),
      class = "locationchoicedatajp_error_medical_institution"
    )
  }
}
