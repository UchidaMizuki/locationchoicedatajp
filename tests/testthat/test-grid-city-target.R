test_that("grid_city_target() declares a target of grid_city_get()", {
  target <- grid_city_target(grid_city, as.Date("2020-10-01"), "1km")

  expect_equal(target$settings$name, "grid_city")
  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "grid_city_get",
      date = "2020-10-01",
      grid_size = "1km",
      .ns = "locationchoicedatajp"
    )
  )
})

test_that("grid_city_target() depends on the URLs of the release", {
  target <- grid_city_target_raw("grid_city", "2020-10-01")
  files <- grid_city_files()
  urls <- files$url[files$boundary_date == as.Date("2020-01-01")]

  expect_length(urls, 47)
  expect_all_true(vapply(
    urls,
    \(url) grepl(url, target$command$string, fixed = TRUE),
    logical(1)
  ))
})
