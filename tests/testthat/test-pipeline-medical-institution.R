test_that("medical_institution_institutions() renames the columns", {
  helpers <- pipeline_helpers()
  institutions <- helpers$medical_institution_institutions(
    fake_medical_institution_layer(),
    2020L,
    6668L
  )

  expect_s3_class(institutions, "sf")
  expect_named(
    institutions,
    c(
      "year",
      "release",
      "institution_type_code",
      "institution_name",
      "address",
      "specialties_1",
      "specialties_2",
      "specialties_3",
      "founder_type_code",
      "beds",
      "emergency_code",
      "disaster_base_code",
      "geometry"
    )
  )
  expect_equal(institutions$institution_type_code, "1")
  expect_equal(institutions$beds, 100L)
  expect_equal(institutions$disaster_base_code, "9")
})

test_that("medical_institution_institutions() errors on unexpected values", {
  helpers <- pipeline_helpers()
  layer <- fake_medical_institution_layer()
  layer$P04_008 <- -1L

  expect_error(
    helpers$medical_institution_institutions(layer, 2020L, 6668L),
    class = "locationchoicedatajp_error_medical_institution"
  )
  point <- sf::st_point()
  layer <- fake_medical_institution_layer()
  sf::st_geometry(layer) <- sf::st_sfc(point, crs = 6668)
  expect_error(
    helpers$medical_institution_institutions(layer, 2020L, 6668L),
    class = "locationchoicedatajp_error_medical_institution"
  )
})
