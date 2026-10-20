test_that("census_city_centroid_files() lists a workbook per year", {
  files <- census_city_centroid_files()

  expect_equal(files$year, c(2015L, 2020L))
  expect_all_true(files$angle %in% c("decimal", "dms"))
})

test_that("census_city_centroid_get() reads the centroids with their terms", {
  local_mocked_bindings(
    census_city_centroid_get_archive = \(year) paste("centroids", year)
  )

  expect_message(
    centroids <- census_city_centroid_get(2020),
    "Terms of use of 人口重心"
  )
  expect_equal(centroids, "centroids 2020")
})

test_that("census_city_centroid_get() errors on a year without centroids", {
  expect_snapshot(error = TRUE, {
    census_city_centroid_get(2010)
    census_city_centroid_get()
  })
})

test_that("census_city_centroid_target() declares a target", {
  target <- census_city_centroid_target(centroids, 2020)

  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "census_city_centroid_get",
      year = 2020,
      .ns = "locationchoicedatajp"
    )
  )
  expect_match(target$command$string, "topics135_10.xlsx", fixed = TRUE)
  expect_equal(
    census_city_centroid_target_name(2015),
    "census_city_centroid_2015"
  )
})
