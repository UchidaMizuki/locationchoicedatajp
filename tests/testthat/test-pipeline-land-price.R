test_that("land_price_sites() takes the columns of the release", {
  helpers <- pipeline_helpers()
  sites <- helpers$land_price_sites(
    fake_land_price_sites(),
    city_code = "L01_017",
    use_code = "L01_001",
    price = "L01_006"
  )

  expect_named(sites, c("city_code", "use_code", "price"))
  expect_equal(sites$city_code, c("13101", "13101", "13101", "01101"))
  expect_equal(sites$price, c(100, 300, 1000, 50))
})

test_that("land_price_sites() errors on unexpected values", {
  helpers <- pipeline_helpers()
  sites <- fake_land_price_sites()
  sites$L01_017[[1]] <- "1310"

  expect_error(
    helpers$land_price_sites(sites, "L01_017", "L01_001", "L01_006"),
    class = "locationchoicedatajp_error_land_price"
  )

  sites <- fake_land_price_sites()
  sites$L01_006[[1]] <- NA
  expect_error(
    helpers$land_price_sites(sites, "L01_017", "L01_001", "L01_006"),
    class = "locationchoicedatajp_error_land_price"
  )
})

test_that("land_price_summarise() summarises by municipality and use", {
  helpers <- pipeline_helpers()
  sites <- helpers$land_price_sites(
    fake_land_price_sites(),
    "L01_017",
    "L01_001",
    "L01_006"
  )
  data <- helpers$land_price_summarise(sites, 2010L)

  expect_named(
    data,
    c(
      "year",
      "release",
      "city_code",
      "use_code",
      "n_points",
      "price_median_jpy_per_m2",
      "price_mean_jpy_per_m2"
    )
  )
  expect_equal(data$year, rep(2010L, 3))
  expect_equal(data$release, rep(2010L, 3))
  expect_equal(data$city_code, c("01101", "13101", "13101"))
  expect_equal(data$use_code, c("000", "000", "005"))
  expect_equal(data$n_points, c(1L, 2L, 1L))
  expect_equal(data$price_median_jpy_per_m2, c(50, 200, 1000))
  expect_equal(data$price_mean_jpy_per_m2, c(50, 200, 1000))
})
