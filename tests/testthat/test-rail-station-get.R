test_that("rail_station_files() has a station layer per year", {
  files <- rail_station_files()

  expect_false(anyNA(files$url))
  expect_match(files$layer, "_Station$")
  expect_all_true(files$epsg %in% c(4612L, 6668L))
  expect_false(2005L %in% files$year)
})

test_that("rail_station_get() reads the stations with their terms", {
  reset_terms("rail_station_get")
  local_mocked_bindings(rail_station_get_archive = \(year) {
    paste("stations", year)
  })

  expect_message(stations <- rail_station_get(2020), "鉄道データ")
  expect_equal(stations, "stations 2020")
})

test_that("rail_station_get() errors on a year without stations", {
  expect_snapshot(error = TRUE, rail_station_get(2010))
})

test_that("rail_station_target() declares a target", {
  target <- rail_station_target(stations, 2020)

  expect_equal(
    target$command$expr[[1]],
    rlang::call2("rail_station_get", year = 2020, .ns = "locationchoicedatajp")
  )
  expect_equal(rail_station_target_name(2020), "rail_station_2020")
})
