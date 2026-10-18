# Helpers of the land price pipeline, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the land prices: one per year of `land_price_files()`. The URL is
# part of the command, so a replaced file rebuilds that year only.
land_price_pipeline <- function() {
  files <- locationchoicedatajp::land_price_files()
  names <- locationchoicedatajp::land_price_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(
      name,
      land_price_build(year, file_name, url, columns, epsg, n_points)
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      columns = land_price_columns(files),
      epsg = files$epsg,
      n_points = files$n_points
    )
  )
}

# The columns of each release that hold the values, as a list of named
# character vectors.
land_price_columns <- function(files) {
  fields <- c("city_code", "use_code", "site_number", "price")
  lapply(seq_len(nrow(files)), \(i) unlist(files[i, fields]))
}

# Sites of a year from the file of its release. `url` is unused: it is an
# argument so that the URL is part of the command.
land_price_build <- function(year, file_name, url, columns, epsg, n_points) {
  # The terms of use are shown by `land_price_get()`, not again by ksjdata in
  # the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  layer <- ksjdata::ksj_get(file_name, col_names = "raw")
  if (nrow(layer) != n_points) {
    rlang::abort(
      sprintf(
        "%s has %d sites, not %d as recorded.",
        file_name,
        nrow(layer),
        n_points
      ),
      class = "locationchoicedatajp_error_land_price"
    )
  }
  land_price_sites(layer, year, columns, epsg)
}

# Sites of a year with the columns of its release, renamed and checked, and
# their points in the coordinate reference system of the release. Files without
# a `.prj` file get the one recorded for their release.
land_price_sites <- function(layer, year, columns, epsg) {
  data <- sf::st_drop_geometry(layer)
  sites <- tibble::tibble(
    year = year,
    release = year,
    city_code = data[[columns[["city_code"]]]],
    use_code = data[[columns[["use_code"]]]],
    site_number = data[[columns[["site_number"]]]],
    price_jpy_per_m2 = as.numeric(data[[columns[["price"]]]])
  )
  land_price_check(
    stringr::str_detect(sites$city_code, "^(0[1-9]|[1-4][0-9])[0-9]{3}$"),
    "municipality codes"
  )
  land_price_check(
    stringr::str_detect(sites$use_code, "^[0-9]{3}$"),
    "use codes"
  )
  land_price_check(
    stringr::str_detect(sites$site_number, "^[0-9]{3}$"),
    "site numbers"
  )
  land_price_check(sites$price_jpy_per_m2 > 0, "prices")

  geometry <- sf::st_geometry(layer)
  if (is.na(sf::st_crs(geometry))) {
    sf::st_crs(geometry) <- epsg
  }
  land_price_check(sf::st_crs(geometry)$epsg == epsg, "coordinate systems")
  sf::st_sf(sites, geometry = geometry)
}

land_price_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the sites are not as expected.", what),
      class = "locationchoicedatajp_error_land_price"
    )
  }
}
