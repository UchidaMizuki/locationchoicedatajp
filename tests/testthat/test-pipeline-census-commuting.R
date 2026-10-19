test_that("census_commuting_flows() gives the flows of each origin", {
  helpers <- pipeline_helpers()
  flows <- helpers$census_commuting_flows(
    fake_census_commuting_cells(),
    c("13101", "13102", "13103")
  )

  expect_named(
    flows,
    c(
      "origin_city_code",
      "destination_city_code",
      "place_code",
      "sex_code",
      "flow"
    )
  )
  first <- flows[flows$origin_city_code == "13101", ]
  expect_equal(first$place_code, c("011", "012", "02", "02", "024", "03"))
  expect_equal(
    first$destination_city_code,
    c("13101", "13101", "13102", "13103", NA, NA)
  )
  expect_equal(first$flow, c(5L, 20L, 30L, 0L, 2L, 1L))
})

test_that("census_commuting_flows() drops the own code under other places", {
  helpers <- pipeline_helpers()
  flows <- helpers$census_commuting_flows(
    fake_census_commuting_cells(),
    c("13101", "13102", "13103")
  )
  other <- flows[flows$place_code == "02", ]

  expect_false(any(other$destination_city_code == other$origin_city_code))
})

test_that("census_commuting_check_totals() compares flows with totals", {
  helpers <- pipeline_helpers()
  flows <- helpers$census_commuting_flows(
    fake_census_commuting_cells(),
    c("13101", "13102", "13103")
  )
  totals <- tibble::tibble(
    origin_city_code = c("13101", "13102"),
    value = c("58", "16")
  )

  expect_no_error(helpers$census_commuting_check_totals(flows, totals))
  totals$value[[1]] <- "59"
  expect_error(
    helpers$census_commuting_check_totals(flows, totals),
    class = "locationchoicedatajp_error_census_commuting"
  )
})

test_that("census_commuting_flows() errors on unexpected values", {
  helpers <- pipeline_helpers()
  cells <- fake_census_commuting_cells()
  cells$value[[1]] <- "x"

  expect_error(
    helpers$census_commuting_flows(cells, c("13101", "13102", "13103")),
    class = "locationchoicedatajp_error_census_commuting"
  )
})

test_that("census_commuting_pipeline() has three targets per table", {
  helpers <- pipeline_helpers()
  targets <- helpers$census_commuting_pipeline()
  names <- vapply(targets, \(target) target$settings$name, character(1))

  expect_length(names, 3 * nrow(census_commuting_tables()))
  expect_contains(
    names,
    c(
      "census_commuting_2020_work_prefectures",
      "census_commuting_2020_work_origins",
      "census_commuting_2020_work"
    )
  )
})

test_that("census_commuting_flows() drops totals among the destinations", {
  helpers <- pipeline_helpers()
  flows <- helpers$census_commuting_flows(
    fake_census_commuting_cells(),
    c("13101", "13102", "13103")
  )

  expect_false("13000" %in% flows$destination_city_code)
})
