test_that("public_facility_files() has the open releases", {
  files <- public_facility_files()

  expect_false(anyNA(files$url))
  expect_all_true(files$epsg == 6668L)
  expect_false(2010L %in% files$year)
})

test_that("public_facility_get() reads the facilities with their terms", {
  reset_terms("public_facility_get")
  local_mocked_bindings(public_facility_get_archive = \(year) {
    paste("facilities", year)
  })

  expect_message(facilities <- public_facility_get(2022), "公的集会施設")
  expect_equal(facilities, "facilities 2022")
})

test_that("public_facility_get() errors on a year without facilities", {
  expect_snapshot(error = TRUE, public_facility_get(2010))
})

test_that("public_facility_target() declares a target", {
  target <- public_facility_target(facilities, 2022)

  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "public_facility_get",
      year = 2022,
      .ns = "locationchoicedatajp"
    )
  )
  expect_equal(public_facility_target_name(2022), "public_facility_2022")
})
