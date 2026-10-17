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
      land_price_build(
        year,
        file_name,
        url,
        city_code,
        use_code,
        price,
        n_points
      )
    ),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      file_name = files$file_name,
      url = files$url,
      city_code = files$city_code,
      use_code = files$use_code,
      price = files$price,
      n_points = files$n_points
    )
  )
}

# Table of a year from the file of its release. `city_code`, `use_code`, and
# `price` are the columns of the release that hold them. `url` is unused: it is
# an argument so that the URL is part of the command.
land_price_build <- function(
  year,
  file_name,
  url,
  city_code,
  use_code,
  price,
  n_points
) {
  # The terms of use are shown by `land_price_get()`, not again by ksjdata in
  # the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  layer <- ksjdata::ksj_get(file_name, col_names = "raw")
  data <- sf::st_drop_geometry(layer)
  sites <- land_price_sites(data, city_code, use_code, price)
  if (nrow(sites) != n_points) {
    rlang::abort(
      sprintf(
        "%s has %d sites, not %d as recorded.",
        file_name,
        nrow(sites),
        n_points
      ),
      class = "locationchoicedatajp_error_land_price"
    )
  }
  land_price_summarise(sites, year)
}

# Sites with the columns of their release, renamed and checked.
land_price_sites <- function(data, city_code, use_code, price) {
  sites <- tibble::tibble(
    city_code = data[[city_code]],
    use_code = data[[use_code]],
    price = as.numeric(data[[price]])
  )
  land_price_check(
    stringr::str_detect(sites$city_code, "^(0[1-9]|[1-4][0-9])[0-9]{3}$"),
    "municipality codes"
  )
  land_price_check(
    stringr::str_detect(sites$use_code, "^[0-9]{3}$"),
    "use codes"
  )
  land_price_check(sites$price > 0, "prices")
  sites
}

land_price_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the sites are not as expected.", what),
      class = "locationchoicedatajp_error_land_price"
    )
  }
}

land_price_summarise <- function(sites, year) {
  sites |>
    dplyr::summarise(
      n_points = dplyr::n(),
      price_median_jpy_per_m2 = stats::median(price),
      price_mean_jpy_per_m2 = mean(price),
      .by = c(city_code, use_code)
    ) |>
    dplyr::mutate(year = year, release = year, .before = 1) |>
    dplyr::arrange(city_code, use_code)
}
