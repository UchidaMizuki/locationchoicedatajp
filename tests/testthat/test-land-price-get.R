test_that("land_price_files() has a file in ksjdata for every year", {
  files <- land_price_files()

  expect_equal(files$year, seq(2007L, max(files$year)))
  expect_false(anyNA(files$url))
  expect_all_true(files$file_name %in% ksjdata::ksj_available$file_name)
  expect_all_true(files$epsg %in% c(4612L, 6668L))
})

test_that("land_price_get() errors on a year without land prices", {
  expect_snapshot(error = TRUE, {
    land_price_get(2006)
    land_price_get(c(2010, 2020))
    land_price_get("2020")
  })
})

test_that("land_price_target_name() names a target per year", {
  expect_equal(
    land_price_target_name(c(2010, 2020)),
    c("land_price_2010", "land_price_2020")
  )
})
