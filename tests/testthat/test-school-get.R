test_that("school_files() has the open releases", {
  files <- school_files()

  expect_false(anyNA(files$url))
  expect_all_true(files$epsg == 6668L)
  expect_false(2013L %in% files$year)
})

test_that("school_get() reads the schools with their terms", {
  local_mocked_bindings(school_get_archive = \(year) paste("schools", year))

  expect_message(schools <- school_get(2023), "学校データ")
  expect_equal(schools, "schools 2023")
})

test_that("school_get() errors on a year without schools", {
  expect_snapshot(error = TRUE, school_get(2013))
})

test_that("school_target() declares a target", {
  target <- school_target(schools, 2023)

  expect_equal(
    target$command$expr[[1]],
    rlang::call2("school_get", year = 2023, .ns = "locationchoicedatajp")
  )
  expect_equal(school_target_name(2023), "school_2023")
})
