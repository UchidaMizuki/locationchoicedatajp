test_that("census_commuting_tables() has one table per year and purpose", {
  tables <- census_commuting_tables()

  expect_false(anyDuplicated(tables[c("year", "purpose")]) > 0)
  expect_all_true(tables$purpose %in% c("work", "school"))
})

test_that("census_commuting_get() reads the flows with their year", {
  local_mocked_bindings(
    census_commuting_get_archive = \(year, purpose) {
      tibble::tibble(origin_city_code = paste(year, purpose))
    }
  )

  expect_message(
    data <- census_commuting_get(2020, "work"),
    "Terms of use"
  )
  expect_equal(data$year, 2020L)
  expect_equal(data$release, 2020L)
  expect_equal(data$origin_city_code, "2020 work")
})

test_that("census_commuting_get() errors on unavailable flows", {
  expect_snapshot(error = TRUE, {
    census_commuting_get(2015, "work")
    census_commuting_get(2020, "shopping")
    census_commuting_get(2020)
  })
})

test_that("census_commuting_target() declares a target of census_commuting_get()", {
  target <- census_commuting_target(commuting, 2020, "school")

  expect_equal(target$settings$name, "commuting")
  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "census_commuting_get",
      year = 2020L,
      purpose = "school",
      .ns = "locationchoicedatajp"
    )
  )
})

test_that("census_commuting_target_name() names a target per table", {
  expect_equal(
    census_commuting_target_name(2020, "work"),
    "census_commuting_2020_work"
  )
})
