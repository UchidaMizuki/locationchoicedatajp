test_that("land_price_grid_summarise() summarises sites by square and use", {
  sites <- sf::st_sf(
    year = 2020L,
    release = 2020L,
    use_code = c("000", "000", "005", "000"),
    price_jpy_per_m2 = c(100, 400, 1000, 50),
    geometry = sf::st_sfc(
      sf::st_point(c(139.701, 35.691)),
      sf::st_point(c(139.7011, 35.6911)),
      sf::st_point(c(139.701, 35.691)),
      sf::st_point(c(135.5, 34.69)),
      crs = 6668
    )
  )
  data <- land_price_grid_summarise(sites, "500m")

  expect_named(
    data,
    c(
      "year",
      "release",
      "grid_code",
      "use_code",
      "n_points",
      "price_median_jpy_per_m2",
      "price_geometric_mean_jpy_per_m2"
    )
  )
  expect_equal(data$grid_code, c("523503294", "533945263", "533945263"))
  expect_equal(data$use_code, c("000", "000", "005"))
  expect_equal(data$n_points, c(1L, 2L, 1L))
  expect_equal(data$price_median_jpy_per_m2, c(50, 250, 1000))
  expect_equal(data$price_geometric_mean_jpy_per_m2, c(50, 200, 1000))
})

test_that("land_price_grid_target() declares a target of land_price_grid_get()", {
  target <- land_price_grid_target(land_price_grid, 2020, "1km")

  expect_equal(target$settings$name, "land_price_grid")
  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "land_price_grid_get",
      year = 2020,
      grid_size = "1km",
      .ns = "locationchoicedatajp"
    )
  )
})

test_that("land_price_grid_get() summarises the sites of the year", {
  local_mocked_bindings(
    land_price_get = function(year) {
      sf::st_sf(
        year = year,
        release = year,
        use_code = "000",
        price_jpy_per_m2 = 100,
        geometry = sf::st_sfc(sf::st_point(c(139.701, 35.691)), crs = 6668)
      )
    }
  )
  data <- land_price_grid_get(2020, "1km")

  expect_equal(data$year, 2020)
  expect_equal(data$grid_code, "53394526")
  expect_equal(data$n_points, 1L)
})
