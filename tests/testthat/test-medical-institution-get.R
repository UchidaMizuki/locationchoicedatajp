test_that("medical_institution_files() has the open releases", {
  files <- medical_institution_files()

  expect_false(anyNA(files$url))
  expect_all_true(files$epsg == 6668L)
  expect_false(any(c(2010L, 2014L) %in% files$year))
})

test_that("medical_institution_get() reads the institutions with their terms", {
  local_mocked_bindings(medical_institution_get_archive = \(year) {
    paste("institutions", year)
  })

  expect_message(institutions <- medical_institution_get(2020), "医療機関")
  expect_equal(institutions, "institutions 2020")
})

test_that("medical_institution_get() errors on a year without institutions", {
  expect_snapshot(error = TRUE, medical_institution_get(2014))
})

test_that("medical_institution_target() declares a target", {
  target <- medical_institution_target(institutions, 2020)

  expect_equal(
    target$command$expr[[1]],
    rlang::call2(
      "medical_institution_get",
      year = 2020,
      .ns = "locationchoicedatajp"
    )
  )
  expect_equal(
    medical_institution_target_name(2020),
    "medical_institution_2020"
  )
})
