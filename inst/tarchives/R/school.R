# Helpers of the schools, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the schools: one per year of `school_files()`. The URL is part of
# the command, so a replaced file rebuilds that year only.
school_pipeline <- function() {
  files <- locationchoicedatajp::school_files()
  names <- locationchoicedatajp::school_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(
      name,
      school_build(year, file_name, url, layer, epsg, n_schools)
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      layer = files$layer,
      epsg = files$epsg,
      n_schools = files$n_schools
    )
  )
}

# Schools of a year from the file of its release. `url` is unused: it is an
# argument so that the URL is part of the command.
school_build <- function(year, file_name, url, layer, epsg, n_schools) {
  # The terms of use are shown by `school_get()`, not again by ksjdata in the
  # process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  data <- ksjdata::ksj_get(file_name, layer = layer, col_names = "raw")
  school_check(nrow(data) == n_schools, "number")
  school_schools(data, year, epsg)
}

# Schools with their columns renamed, as published. Codes stored as numbers in
# the files of 2021 are kept as character. The campus code and its note are
# published from 2023 and are `NA` before.
school_schools <- function(data, year, epsg) {
  column <- \(name) if (name %in% names(data)) data[[name]] else NA_character_
  schools <- tibble::tibble(
    year = year,
    release = year,
    city_code = as.character(data$P29_001),
    school_code = as.character(data$P29_002),
    school_type_code = as.character(data$P29_003),
    school_name = data$P29_004,
    address = data$P29_005,
    administrator_code = as.character(data$P29_006),
    closure_code = as.character(data$P29_007),
    campus_code = as.character(column("P29_008")),
    campus_note = column("P29_009")
  )
  school_check(grepl("^[0-9]{5}$", schools$city_code), "municipalities")
  school_check(schools$school_type_code %in% school_type_codes(), "types")
  school_check(
    schools$administrator_code %in% c("0", "1", "2", "3", "4"),
    "administrators"
  )
  school_check(!is.na(schools$school_name), "names")

  geometry <- sf::st_geometry(data)
  school_check(sf::st_crs(geometry)$epsg == epsg, "coordinate systems")
  school_check(
    sf::st_geometry_type(geometry) == "POINT" & !sf::st_is_empty(geometry),
    "locations"
  )
  sf::st_sf(schools, geometry = geometry)
}

# Codes of 学校分類コード (SchoolClassCd).
school_type_codes <- function() {
  as.character(c(16001:16007, 16011:16016))
}

school_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the schools are not as expected.", what),
      class = "locationchoicedatajp_error_school"
    )
  }
}
