# Environment with the helpers shared by the bundled pipelines.
pipeline_helpers <- function() {
  env <- new.env()
  tarchives::tar_source_archive("locationchoicedatajp", envir = env)
  env
}

# Sites of land prices in the layout of a release before 2024, where the use
# is in `L01_001`, the serial number in `L01_002`, the price in `L01_006`, and
# the municipality in `L01_017`, without a coordinate reference system.
fake_land_price_layer <- function(crs = sf::NA_crs_) {
  data <- tibble::tibble(
    L01_001 = c("000", "005"),
    L01_002 = c("001", "002"),
    L01_006 = c("100", "1000"),
    L01_017 = c("13101", "01101")
  )
  points <- list(sf::st_point(c(139.7, 35.7)), sf::st_point(c(141.3, 43.1)))
  sf::st_sf(data, geometry = sf::st_sfc(points, crs = crs))
}

fake_land_price_columns <- function() {
  c(
    city_code = "L01_017",
    use_code = "L01_001",
    site_number = "L01_002",
    price = "L01_006"
  )
}
