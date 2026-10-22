# Helpers of the railway lines, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the lines: one per year of `rail_line_files()`. The URL is part of
# the command, so a replaced file rebuilds that year only.
rail_line_pipeline <- function() {
  files <- locationchoicedatajp::rail_line_files()
  names <- locationchoicedatajp::rail_line_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(
      name,
      rail_line_build(year, file_name, url, layer, epsg, n_sections)
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      layer = files$layer,
      epsg = files$epsg,
      n_sections = files$n_sections
    )
  )
}

# Sections of a year from the file of its release. `url` is unused: it is an
# argument so that the URL is part of the command.
rail_line_build <- function(year, file_name, url, layer, epsg, n_sections) {
  # The terms of use are shown by `rail_line_get()`, not again by ksjdata in
  # the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  data <- ksjdata::ksj_get(file_name, layer = layer, col_names = "raw")
  rail_line_check(nrow(data) == n_sections, "number")
  rail_line_sections(data, year, epsg)
}

# Sections with their columns renamed, as published. Files without a `.prj`
# file get the coordinate reference system recorded for their release.
rail_line_sections <- function(data, year, epsg) {
  sections <- tibble::tibble(
    year = year,
    release = year,
    railway_type_code = data$N02_001,
    operator_type_code = data$N02_002,
    line_name = data$N02_003,
    operator_name = data$N02_004
  )
  rail_line_check(
    sections$railway_type_code %in% as.character(c(11:17, 21:25)),
    "railway types"
  )
  rail_line_check(
    sections$operator_type_code %in% as.character(1:5),
    "operator types"
  )
  rail_line_check(!is.na(sections$line_name), "names")

  geometry <- sf::st_geometry(data)
  if (is.na(sf::st_crs(geometry))) {
    sf::st_crs(geometry) <- epsg
  }
  rail_line_check(sf::st_crs(geometry)$epsg == epsg, "coordinate systems")
  rail_line_check(!sf::st_is_empty(geometry), "geometries")
  sf::st_sf(sections, geometry = geometry)
}

rail_line_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the railway lines are not as expected.", what),
      class = "locationchoicedatajp_error_rail_line"
    )
  }
}
