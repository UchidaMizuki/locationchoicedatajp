test_that("rail_line_files() has a layer of sections per year of the stations", {
  files <- rail_line_files()

  expect_false(anyNA(files$url))
  expect_match(files$layer, "_RailroadSection$")
  expect_equal(files$file_name, rail_station_files()$file_name)
})

test_that("rail_line_get() reads the lines with their terms", {
  reset_terms("rail_line_get")
  local_mocked_bindings(rail_line_get_archive = \(year) paste("lines", year))

  expect_message(lines <- rail_line_get(2020), "鉄道データ")
  expect_equal(lines, "lines 2020")
})

test_that("rail_line_get() errors on a year without lines", {
  expect_snapshot(error = TRUE, rail_line_get(2010))
})

test_that("rail_line_target() declares a target", {
  target <- rail_line_target(lines, 2020)

  expect_equal(
    target$command$expr[[1]],
    rlang::call2("rail_line_get", year = 2020, .ns = "locationchoicedatajp")
  )
  expect_equal(rail_line_target_name(2020), "rail_line_2020")
})
