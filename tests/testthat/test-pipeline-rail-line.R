test_that("rail_line_sections() renames the columns of a release", {
  helpers <- pipeline_helpers()
  sections <- helpers$rail_line_sections(fake_rail_line_layer(), 2014L, 4612L)

  expect_s3_class(sections, "sf")
  expect_named(
    sections,
    c(
      "year",
      "release",
      "railway_type_code",
      "operator_type_code",
      "line_name",
      "operator_name",
      "geometry"
    )
  )
  expect_equal(sections$line_name, "山手線")
  expect_equal(sf::st_crs(sections)$epsg, 4612L)
})

test_that("rail_line_sections() errors on unexpected values", {
  helpers <- pipeline_helpers()
  layer <- fake_rail_line_layer()
  layer$N02_001 <- "99"

  expect_error(
    helpers$rail_line_sections(layer, 2014L, 4612L),
    class = "locationchoicedatajp_error_rail_line"
  )
  expect_error(
    helpers$rail_line_sections(fake_rail_line_layer(crs = 6668), 2014L, 4612L),
    class = "locationchoicedatajp_error_rail_line"
  )
})
