test_that("grid_city_files() has the files by prefecture of every release", {
  files <- grid_city_files()

  expect_false(anyNA(files$boundary_date))
  expect_all_equal(as.vector(table(files$boundary_date)), 47L)
  expect_false(anyDuplicated(files$file_name) > 0)
  expect_equal(files$boundary_date, sort(files$boundary_date))
})

test_that("grid_city_release_date() takes the release in force on a date", {
  files <- tibble::tibble(
    boundary_date = as.Date(c("2010-10-01", "2011-03-31", "2015-01-01"))
  )

  expect_equal(
    grid_city_release_date(as.Date("2011-03-31"), files),
    as.Date("2011-03-31")
  )
  expect_equal(
    grid_city_release_date(as.Date("2014-12-31"), files),
    as.Date("2011-03-31")
  )
})

test_that("grid_city_get() reads the crosswalk of the release in force", {
  local_mocked_bindings(
    grid_city_get_archive = function(boundary_date, grid_size) {
      tibble::tibble(
        grid_code = paste(format(boundary_date), grid_size),
        city_code = "13101",
        area_m2 = 1,
        share = 1
      )
    }
  )
  data <- suppressMessages(grid_city_get("2020-10-01", grid_size = "1km"))

  expect_named(
    data,
    c("boundary_date", "release", "grid_code", "city_code", "area_m2", "share")
  )
  expect_equal(data$boundary_date, as.Date("2020-01-01"))
  expect_equal(data$release, 2020L)
  expect_equal(data$grid_code, "2020-01-01 1km")
})

test_that("grid_city_get() errors on an invalid date", {
  expect_snapshot(error = TRUE, {
    grid_city_get("2020-13-01")
    grid_city_get(2020)
    grid_city_get("2000-01-01")
  })
})

test_that("grid_city_release_target_name() names a target per release", {
  expect_equal(
    grid_city_release_target_name(
      as.Date(c("2010-10-01", "2020-01-01")),
      "1km"
    ),
    c("grid_city_20101001_1km", "grid_city_20200101_1km")
  )
})
