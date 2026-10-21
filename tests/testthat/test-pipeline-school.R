test_that("school_schools() renames the columns of a release", {
  helpers <- pipeline_helpers()
  schools <- helpers$school_schools(fake_school_layer(), 2021L, 6668L)

  expect_s3_class(schools, "sf")
  expect_named(
    schools,
    c(
      "year",
      "release",
      "city_code",
      "school_code",
      "school_type_code",
      "school_name",
      "address",
      "administrator_code",
      "closure_code",
      "campus_code",
      "campus_note",
      "geometry"
    )
  )
  expect_equal(schools$school_type_code, "16001")
  expect_equal(schools$administrator_code, "3")
  expect_equal(schools$campus_code, NA_character_)
})

test_that("school_schools() keeps the campus from 2023", {
  helpers <- pipeline_helpers()
  layer <- fake_school_layer()
  layer$P29_008 <- "01"
  layer$P29_009 <- "本校"
  schools <- helpers$school_schools(layer, 2023L, 6668L)

  expect_equal(schools$campus_code, "01")
  expect_equal(schools$campus_note, "本校")
})

test_that("school_schools() errors on codes outside their lists", {
  helpers <- pipeline_helpers()
  layer <- fake_school_layer()
  layer$P29_003 <- 99999L

  expect_error(
    helpers$school_schools(layer, 2021L, 6668L),
    class = "locationchoicedatajp_error_school"
  )
  expect_error(
    helpers$school_schools(fake_school_layer(crs = 4612), 2021L, 6668L),
    class = "locationchoicedatajp_error_school"
  )
})
