test_that("census_grid_tables() has one table per year, size, and number", {
  tables <- census_grid_tables()

  expect_false(anyDuplicated(tables$stats_id) > 0)
  expect_false(anyDuplicated(tables[c("year", "grid_size", "table_code")]) > 0)
  expect_all_true(tables$grid_size %in% grid_sizes())
  expect_setequal(unique(tables$year), c(2010L, 2015L, 2020L))
})

test_that("census_grid_items() has the items of every table", {
  items <- census_grid_items()

  expect_setequal(unique(items$stats_id), census_grid_tables()$stats_id)
  expect_all_true(startsWith(items$item_code, items$stats_id))
  expect_false(anyNA(items$unit))
})

test_that("census_grid_primary_grids() has four-digit codes", {
  expect_match(census_grid_primary_grids(), "^[0-9]{4}$")
})

test_that("census_grid_get() reads the table with its year", {
  local_mocked_bindings(
    census_grid_get_archive = \(stats_id) tibble::tibble(grid_code = stats_id)
  )

  expect_message(
    data <- census_grid_get(2020, "500m", "001-01"),
    "Terms of use"
  )
  expect_equal(data$year, 2020L)
  expect_equal(data$release, 2020L)
  expect_equal(data$grid_code, "T001141")
})

test_that("census_grid_get() errors on a table that does not exist", {
  expect_snapshot(error = TRUE, {
    census_grid_get(2010, "500m", "001-02")
    census_grid_get(2020, "500m")
  })
})

test_that("census_grid_target() declares a target of census_grid_get()", {
  target <- census_grid_target(population, 2020, "500m", "001-01")

  expect_equal(target$settings$name, "population")
  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "census_grid_get",
      year = 2020L,
      grid_size = "500m",
      table_code = "001-01",
      .ns = "locationchoicedatajp"
    )
  )
})

test_that("census_grid_target_name() names a target per table", {
  expect_equal(census_grid_target_name("T001141"), "census_grid_t001141")
})
