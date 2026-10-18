test_that("land_price_target() declares a target of land_price_get()", {
  target <- land_price_target(land_price, 2020)

  expect_s3_class(target, "tar_target")
  expect_equal(target$settings$name, "land_price")
  expect_equal(
    target$command$expr[[1]],
    rlang::call2("land_price_get", year = 2020, .ns = "locationchoicedatajp")
  )
})

test_that("land_price_target_raw() takes the name as a string", {
  target <- land_price_target_raw("land_price", 2020)

  expect_equal(target$settings$name, "land_price")
})

test_that("land_price_target() depends on the URL of the file", {
  target <- land_price_target(land_price, 2020)
  files <- land_price_files()

  expect_match(
    target$command$string,
    files$url[files$year == 2020],
    fixed = TRUE
  )
})
