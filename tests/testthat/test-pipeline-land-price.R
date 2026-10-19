test_that("land_price_sites() takes the columns of the release", {
  helpers <- pipeline_helpers()
  sites <- helpers$land_price_sites(
    fake_land_price_layer(),
    2010L,
    fake_land_price_columns(),
    4612L
  )

  expect_s3_class(sites, "sf")
  expect_named(
    sites,
    c(
      "year",
      "release",
      "city_code",
      "use_code",
      "site_number",
      "price_jpy_per_m2",
      "geometry"
    )
  )
  expect_equal(sites$year, c(2010L, 2010L))
  expect_equal(sites$release, c(2010L, 2010L))
  expect_equal(sites$city_code, c("13101", "01101"))
  expect_equal(sites$site_number, c("001", "002"))
  expect_equal(sites$price_jpy_per_m2, c(100, 1000))
})

test_that("land_price_sites() sets the recorded system of a file without one", {
  helpers <- pipeline_helpers()
  sites <- helpers$land_price_sites(
    fake_land_price_layer(),
    2010L,
    fake_land_price_columns(),
    4612L
  )

  expect_equal(sf::st_crs(sites)$epsg, 4612L)
})

test_that("land_price_sites() errors on a system other than the recorded one", {
  helpers <- pipeline_helpers()

  expect_error(
    helpers$land_price_sites(
      fake_land_price_layer(crs = 6668),
      2024L,
      fake_land_price_columns(),
      4612L
    ),
    class = "locationchoicedatajp_error_land_price"
  )
})

test_that("land_price_sites() errors on unexpected values", {
  helpers <- pipeline_helpers()
  layer <- fake_land_price_layer()
  layer$L01_017[[1]] <- "1310"

  expect_error(
    helpers$land_price_sites(layer, 2010L, fake_land_price_columns(), 4612L),
    class = "locationchoicedatajp_error_land_price"
  )

  layer <- fake_land_price_layer()
  layer$L01_006[[1]] <- NA
  expect_error(
    helpers$land_price_sites(layer, 2010L, fake_land_price_columns(), 4612L),
    class = "locationchoicedatajp_error_land_price"
  )
})

test_that("land_price_columns() lists the columns of each release", {
  helpers <- pipeline_helpers()
  files <- land_price_files()
  columns <- helpers$land_price_columns(files)

  expect_length(columns, nrow(files))
  expect_equal(
    columns[[1]],
    c(
      city_code = files$city_code[[1]],
      use_code = files$use_code[[1]],
      site_number = files$site_number[[1]],
      price = files$price[[1]]
    )
  )
})

test_that("prefectural_land_price_build() converts forest land to square meters", {
  helpers <- pipeline_helpers()
  helpers$land_price_build <- function(...) {
    tibble::tibble(use_code = c("000", "020"), price_jpy_per_m2 = c(1000, 5000))
  }
  sites <- helpers$prefectural_land_price_build()

  expect_equal(sites$price_jpy_per_m2, c(1000, 5))
})

test_that("land_price_pipeline() builds each year with its function", {
  helpers <- pipeline_helpers()
  official <- helpers$land_price_pipeline()
  files <- prefectural_land_price_files()
  prefectural <- helpers$land_price_pipeline(
    files = files,
    names = prefectural_land_price_target_name(files$year),
    build = "prefectural_land_price_build"
  )

  expect_equal(official[[1]]$settings$name, "land_price_2007")
  expect_equal(
    as.character(official[[1]]$command$expr[[1]][[1]]),
    "land_price_build"
  )
  expect_equal(prefectural[[1]]$settings$name, "prefectural_land_price_2006")
  expect_equal(
    as.character(prefectural[[1]]$command$expr[[1]][[1]]),
    "prefectural_land_price_build"
  )
})
