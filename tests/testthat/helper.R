# Environment with the helpers shared by the bundled pipelines.
pipeline_helpers <- function() {
  env <- new.env()
  tarchives::tar_source_archive("locationchoicedatajp", envir = env)
  env
}

# Sites of land prices in the layout of a release before 2024, where the use
# is in `L01_001`, the price in `L01_006`, and the municipality in `L01_017`.
fake_land_price_sites <- function() {
  tibble::tibble(
    L01_001 = c("000", "000", "005", "000"),
    L01_006 = c("100", "300", "1000", "50"),
    L01_017 = c("13101", "13101", "13101", "01101")
  )
}
