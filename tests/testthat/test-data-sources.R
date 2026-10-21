test_that("data_sources() has a source for every getter with data", {
  getters <- grep(
    "_get$",
    getNamespaceExports("locationchoicedatajp"),
    value = TRUE
  )
  sources <- data_sources()

  expect_setequal(sources$function_name, getters)
  expect_false(anyNA(sources[c(
    "source_name",
    "license_name",
    "license_url",
    "attribution"
  )]))
  expect_all_true(grepl("加工して作成", sources$attribution))
})

test_that("data_sources() has the columns of the registry", {
  expect_named(
    data_sources(),
    c(
      "function_name",
      "source_name",
      "publisher",
      "source_url",
      "license_name",
      "license_note",
      "license_url",
      "attribution"
    )
  )
})

test_that("data_attribution() gives the distinct lines of the getters", {
  lines <- data_attribution(c("land_price_get", "land_price_grid_get"))

  expect_length(lines, 1)
  expect_match(lines, "地価公示データ")
  expect_length(data_attribution(), length(unique(data_sources()$attribution)))
})

test_that("data_attribution() errors on unknown functions", {
  expect_snapshot(error = TRUE, data_attribution("grid_code"))
})
