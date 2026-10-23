test_that("public_facility_facilities() renames the columns", {
  helpers <- pipeline_helpers()
  facilities <- helpers$public_facility_facilities(
    fake_public_facility_layer(),
    2022L,
    6668L
  )

  expect_s3_class(facilities, "sf")
  expect_named(
    facilities,
    c(
      "year",
      "release",
      "city_code",
      "facility_type_code",
      "facility_name",
      "address",
      "geometry"
    )
  )
  expect_equal(facilities$facility_type_code, "1")
})

test_that("public_facility_facilities() errors on unexpected values", {
  helpers <- pipeline_helpers()
  layer <- fake_public_facility_layer()
  layer$P05_002 <- "9"

  expect_error(
    helpers$public_facility_facilities(layer, 2022L, 6668L),
    class = "locationchoicedatajp_error_public_facility"
  )
  expect_error(
    helpers$public_facility_facilities(
      fake_public_facility_layer(crs = 4612),
      2022L,
      6668L
    ),
    class = "locationchoicedatajp_error_public_facility"
  )
})
