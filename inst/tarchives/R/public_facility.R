# Helpers of the municipal offices and public meeting facilities, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the facilities: one per year of `public_facility_files()`. The URL
# is part of the command, so a replaced file rebuilds that year only.
public_facility_pipeline <- function() {
  files <- locationchoicedatajp::public_facility_files()
  names <- locationchoicedatajp::public_facility_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(
      name,
      public_facility_build(
        year,
        file_name,
        url,
        layer_prefix,
        epsg,
        n_facilities
      )
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      layer_prefix = files$layer_prefix,
      epsg = files$epsg,
      n_facilities = files$n_facilities
    )
  )
}

# Facilities of a year from the file of its release, which has a layer per
# prefecture in the same layout. `url` is unused: it is an argument so that the
# URL is part of the command.
public_facility_build <- function(
  year,
  file_name,
  url,
  layer_prefix,
  epsg,
  n_facilities
) {
  # The terms of use are shown by `public_facility_get()`, not again by ksjdata
  # in the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  layers <- sprintf("%s_%02d", layer_prefix, 1:47)
  facilities <- lapply(layers, \(layer) {
    data <- ksjdata::ksj_get(file_name, layer = layer, col_names = "raw")
    public_facility_facilities(data, year, epsg)
  })
  facilities <- do.call(rbind, facilities)
  public_facility_check(nrow(facilities) == n_facilities, "number")
  facilities
}

# Facilities with their columns renamed, as published.
public_facility_facilities <- function(data, year, epsg) {
  facilities <- tibble::tibble(
    year = year,
    release = year,
    city_code = data$P05_001,
    facility_type_code = data$P05_002,
    facility_name = data$P05_003,
    address = data$P05_004
  )
  check <- public_facility_check
  check(grepl("^[0-9]{5}$", facilities$city_code), "municipalities")
  check(facilities$facility_type_code %in% as.character(1:5), "types")
  check(!is.na(facilities$facility_name), "names")

  geometry <- sf::st_geometry(data)
  check(sf::st_crs(geometry)$epsg == epsg, "coordinate systems")
  check(
    sf::st_geometry_type(geometry) == "POINT" & !sf::st_is_empty(geometry),
    "locations"
  )
  sf::st_sf(facilities, geometry = geometry)
}

public_facility_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the public facilities are not as expected.", what),
      class = "locationchoicedatajp_error_public_facility"
    )
  }
}
