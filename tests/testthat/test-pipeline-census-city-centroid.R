test_that("census_city_centroid_rows() reads the rows below the headers", {
  helpers <- pipeline_helpers()
  cells <- tibble::tibble(
    a = c("コード", "", "13000", "13101", "注）..."),
    b = c("名称", "", "東京都", "千代田区", NA),
    c = c("経度", "", "139.7", "139.75", NA),
    d = c("緯度", "", "35.7", "35.69", NA)
  )
  rows <- helpers$census_city_centroid_rows(cells)

  expect_equal(rows$city_code, c("13000", "13101"))
  expect_equal(rows$longitude, c("139.7", "139.75"))
})

test_that("census_city_centroid_points() keeps municipalities with centroids", {
  helpers <- pipeline_helpers()
  rows <- tibble::tibble(
    city_code = c("07000", "07543", "07546", "13101"),
    city_name = c("福島県", "富岡町", "双葉町注）", "千代田区"),
    longitude = c("140.4", "141.0", NA, "139.75"),
    latitude = c("37.4", "37.3", NA, "35.69")
  )
  points <- helpers$census_city_centroid_points(rows, 2020L, "decimal")

  expect_s3_class(points, "sf")
  expect_named(points, c("year", "release", "city_code", "geometry"))
  expect_equal(points$city_code, c("07543", "13101"))
  expect_equal(sf::st_crs(points)$epsg, 4612L)
  expect_equal(sf::st_coordinates(points)[2, ], c(X = 139.75, Y = 35.69))
})

test_that("census_city_centroid_points() errors on a centroid without a note", {
  helpers <- pipeline_helpers()
  rows <- tibble::tibble(
    city_code = "13101",
    city_name = "千代田区",
    longitude = NA_character_,
    latitude = NA_character_
  )

  expect_error(
    helpers$census_city_centroid_points(rows, 2020L, "decimal"),
    class = "locationchoicedatajp_error_census_city_centroid"
  )
})

test_that("census_city_centroid_angle() reads degrees, minutes, and seconds", {
  helpers <- pipeline_helpers()

  expect_equal(
    helpers$census_city_centroid_angle("1404411.91", "dms"),
    140 + 44 / 60 + 11.91 / 3600
  )
  expect_equal(helpers$census_city_centroid_angle("140.5", "decimal"), 140.5)
})
