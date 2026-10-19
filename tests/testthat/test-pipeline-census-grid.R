test_that("census_grid_read() reads a file as published", {
  helpers <- pipeline_helpers()
  file <- local_census_grid_file(fake_census_grid_lines())
  data <- helpers$census_grid_read(file, "500m", c("T001141001", "T001141034"))

  expect_named(
    data,
    c(
      "grid_code",
      "suppression_code",
      "merged_into_grid_code",
      "T001141001",
      "T001141034"
    )
  )
  expect_equal(data$grid_code, c("533900054", "533900064", "533900073"))
  expect_equal(data$suppression_code, c("0", "2", "1"))
  expect_equal(data$merged_into_grid_code, c(NA, "533900073", NA))
  expect_equal(data$T001141001, c(52L, 3L, 40L))
  expect_equal(data$T001141034, c(20L, NA, 15L))
})

test_that("census_grid_read() reads the tables of 2010 without suppression", {
  helpers <- pipeline_helpers()
  file <- local_census_grid_file(c(
    "KEY_CODE,T000609001",
    ",人口総数",
    "533900053,6"
  ))
  data <- helpers$census_grid_read(file, "500m", "T000609001")

  expect_equal(data$suppression_code, NA_character_)
  expect_equal(data$merged_into_grid_code, NA_character_)
  expect_equal(data$T000609001, 6L)
})

test_that("census_grid_read() gives no rows for a square without a file", {
  helpers <- pipeline_helpers()
  data <- helpers$census_grid_read(NULL, "500m", "T001141001")

  expect_equal(nrow(data), 0)
  expect_named(
    data,
    c("grid_code", "suppression_code", "merged_into_grid_code", "T001141001")
  )
})

test_that("census_grid_read() errors on unexpected files", {
  helpers <- pipeline_helpers()
  file <- local_census_grid_file(fake_census_grid_lines())

  expect_error(
    helpers$census_grid_read(file, "500m", "T001141001"),
    class = "locationchoicedatajp_error_census_grid"
  )
  expect_error(
    helpers$census_grid_read(file, "1km", c("T001141001", "T001141034")),
    class = "locationchoicedatajp_error_census_grid"
  )
})

test_that("census_grid_pipeline() has three targets per table", {
  helpers <- pipeline_helpers()
  targets <- helpers$census_grid_pipeline()
  names <- vapply(targets, \(target) target$settings$name, character(1))

  expect_length(names, 3 * nrow(census_grid_tables()))
  expect_contains(
    names,
    c(
      "census_grid_t001141_primary_grids",
      "census_grid_t001141_files",
      "census_grid_t001141"
    )
  )
})

test_that("census_grid_is_archive() tells archives of one file from others", {
  helpers <- pipeline_helpers()
  dir <- withr::local_tempdir()
  writeLines("x", file.path(dir, "a.txt"))
  writeLines("y", file.path(dir, "b.txt"))
  archive <- file.path(dir, "archive.zip")
  two <- file.path(dir, "two.zip")
  page <- file.path(dir, "page.zip")
  withr::with_dir(dir, {
    zip::zip(archive, "a.txt")
    zip::zip(two, c("a.txt", "b.txt"))
  })
  writeLines("<html></html>", page)

  expect_identical(helpers$census_grid_is_archive(archive), TRUE)
  expect_identical(helpers$census_grid_is_archive(two), FALSE)
  expect_identical(helpers$census_grid_is_archive(page), FALSE)
})
