test_that("rail_station_stations() renames the columns of a release", {
  helpers <- pipeline_helpers()
  stations <- helpers$rail_station_stations(
    fake_rail_station_layer(),
    2014L,
    4612L
  )

  expect_s3_class(stations, "sf")
  expect_named(
    stations,
    c(
      "year",
      "release",
      "railway_type_code",
      "operator_type_code",
      "line_name",
      "operator_name",
      "station_name",
      "station_code",
      "station_group_code",
      "geometry"
    )
  )
  expect_equal(stations$station_name, "東京")
  expect_equal(stations$station_code, NA_character_)
  expect_equal(sf::st_crs(stations)$epsg, 4612L)
})

test_that("rail_station_stations() keeps the codes from 2022", {
  helpers <- pipeline_helpers()
  layer <- fake_rail_station_layer(crs = 6668)
  layer$N02_005c <- "003700"
  layer$N02_005g <- "003700"
  stations <- helpers$rail_station_stations(layer, 2022L, 6668L)

  expect_equal(stations$station_code, "003700")
  expect_equal(stations$station_group_code, "003700")
})

test_that("rail_station_stations() errors on another coordinate system", {
  helpers <- pipeline_helpers()

  expect_error(
    helpers$rail_station_stations(
      fake_rail_station_layer(crs = 6668),
      2014L,
      4612L
    ),
    class = "locationchoicedatajp_error_rail_station"
  )
})
