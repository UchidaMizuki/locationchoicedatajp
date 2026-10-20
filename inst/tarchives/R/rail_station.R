# Helpers of the railway stations, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the stations: one per year of `rail_station_files()`. The URL is
# part of the command, so a replaced file rebuilds that year only.
rail_station_pipeline <- function() {
  files <- locationchoicedatajp::rail_station_files()
  names <- locationchoicedatajp::rail_station_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(
      name,
      rail_station_build(year, file_name, url, layer, epsg, n_stations)
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      layer = files$layer,
      epsg = files$epsg,
      n_stations = files$n_stations
    )
  )
}

# Stations of a year from the file of its release. `url` is unused: it is an
# argument so that the URL is part of the command.
rail_station_build <- function(year, file_name, url, layer, epsg, n_stations) {
  # The terms of use are shown by `rail_station_get()`, not again by ksjdata in
  # the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  data <- ksjdata::ksj_get(file_name, layer = layer, col_names = "raw")
  rail_station_check(nrow(data) == n_stations, "number")
  rail_station_stations(data, year, epsg)
}

# Stations with their columns renamed, as published. The station and group
# codes are published from 2022 and are `NA` before. Files without a `.prj`
# file get the coordinate reference system recorded for their release.
rail_station_stations <- function(data, year, epsg) {
  column <- \(name) if (name %in% names(data)) data[[name]] else NA_character_
  stations <- tibble::tibble(
    year = year,
    release = year,
    railway_type_code = data$N02_001,
    operator_type_code = data$N02_002,
    line_name = data$N02_003,
    operator_name = data$N02_004,
    station_name = data$N02_005,
    station_code = column("N02_005c"),
    station_group_code = column("N02_005g")
  )
  rail_station_check(!is.na(stations$station_name), "names")

  geometry <- sf::st_geometry(data)
  if (is.na(sf::st_crs(geometry))) {
    sf::st_crs(geometry) <- epsg
  }
  rail_station_check(sf::st_crs(geometry)$epsg == epsg, "coordinate systems")
  sf::st_sf(stations, geometry = geometry)
}

rail_station_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the stations are not as expected.", what),
      class = "locationchoicedatajp_error_rail_station"
    )
  }
}
