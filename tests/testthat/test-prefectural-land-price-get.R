test_that("prefectural_land_price_files() has a file in ksjdata for every year", {
  files <- prefectural_land_price_files()

  expect_equal(files$year, seq(2006L, max(files$year)))
  expect_false(anyNA(files$url))
  expect_all_true(files$epsg %in% c(4612L, 6668L))
})

test_that("prefectural_land_price_get() reads the sites with their terms", {
  local_mocked_bindings(
    prefectural_land_price_get_archive = \(year) paste("sites", year)
  )

  expect_message(
    sites <- prefectural_land_price_get(2020),
    "Terms of use of L02"
  )
  expect_equal(sites, "sites 2020")
})

test_that("prefectural_land_price_get() errors on a year without prices", {
  expect_snapshot(error = TRUE, prefectural_land_price_get(2005))
})

test_that("prefectural_land_price_target() declares a target", {
  target <- prefectural_land_price_target(prices, 2020)
  files <- prefectural_land_price_files()

  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "prefectural_land_price_get",
      year = 2020,
      .ns = "locationchoicedatajp"
    )
  )
  expect_match(
    target$command$string,
    files$url[files$year == 2020],
    fixed = TRUE
  )
})
