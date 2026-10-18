test_that("grid_city_areas() cuts municipalities by grid squares", {
  helpers <- pipeline_helpers()
  areas <- helpers$grid_city_areas(fake_city_layer())

  expect_named(areas, c("grid_code", "city_code", "area_m2"))
  expect_equal(
    paste(areas$grid_code, areas$city_code),
    c("533945092 13101", "533945092 13102", "533946001 13102")
  )
  expect_all_true(areas$area_m2 > 0)
})

test_that("grid_city_areas() keeps the area of the municipalities", {
  helpers <- pipeline_helpers()
  layer <- fake_city_layer()
  areas <- helpers$grid_city_areas(layer)

  sf::st_crs(layer) <- 4612
  equal_area <- "+proj=aea +lat_0=36 +lon_0=136 +lat_1=25 +lat_2=47 +ellps=GRS80 +units=m"
  expected <- as.numeric(sf::st_area(sf::st_transform(layer, equal_area)))
  expect_equal(sum(areas$area_m2), sum(expected), tolerance = 1e-6)
})

test_that("grid_city_combine() gives shares over all prefectures", {
  helpers <- pipeline_helpers()
  areas <- fake_grid_city_areas()
  data <- helpers$grid_city_combine(areas[1, ], areas[-1, ])

  expect_named(data, c("grid_code", "city_code", "area_m2", "share"))
  expect_equal(data$grid_code, areas$grid_code)
  expect_equal(data$share, c(0.25, 0.75, 1, 1))
})

test_that("grid_city_coarsen() sums 500 m squares into 1 km squares", {
  helpers <- pipeline_helpers()
  data <- helpers$grid_city_coarsen(helpers$grid_city_combine(
    fake_grid_city_areas()
  ))

  expect_equal(data$grid_code, c("53394509", "53394509", "53394509"))
  expect_equal(data$city_code, c("13101", "13102", NA))
  expect_equal(data$area_m2, c(100, 700, 200))
  expect_equal(data$share, c(0.1, 0.7, 0.2))
})

test_that("grid_city_pipeline() has two targets per release", {
  helpers <- pipeline_helpers()
  targets <- helpers$grid_city_pipeline()
  names <- vapply(
    unlist(targets, recursive = TRUE),
    \(target) target$settings$name,
    character(1)
  )
  files <- grid_city_files()

  expect_length(names, nrow(files) + 2 * length(unique(files$boundary_date)))
  expect_contains(
    names,
    c(
      "grid_city_20200101_13",
      "grid_city_20200101_500m",
      "grid_city_20200101_1km"
    )
  )
})
