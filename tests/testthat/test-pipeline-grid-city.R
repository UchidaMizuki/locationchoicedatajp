test_that("grid_city_dissolve() dissolves polygons by municipality", {
  helpers <- pipeline_helpers()
  layer <- fake_city_layer()
  layer <- rbind(layer, layer[1, ])
  sf::st_crs(layer) <- 4612
  cities <- helpers$grid_city_dissolve(layer)

  expect_equal(cities$city_code, c("13101", "13102"))
})

test_that("grid_city_areas() cuts municipalities by grid squares of a size", {
  helpers <- pipeline_helpers()
  cities <- fake_city_layer()
  sf::st_crs(cities) <- 4612
  names(cities)[[1]] <- "city_code"
  areas <- helpers$grid_city_areas(cities, "500m")

  expect_named(areas, c("grid_code", "city_code", "area_m2"))
  expect_equal(
    paste(areas$grid_code, areas$city_code),
    c("533945092 13101", "533945092 13102", "533946001 13102")
  )
  expect_all_true(areas$area_m2 > 0)

  equal_area <- "+proj=aea +lat_0=36 +lon_0=136 +lat_1=25 +lat_2=47 +ellps=GRS80 +units=m"
  expected <- as.numeric(sf::st_area(sf::st_transform(cities, equal_area)))
  expect_equal(sum(areas$area_m2), sum(expected), tolerance = 1e-6)
  expect_equal(
    sum(helpers$grid_city_areas(cities, "1km")$area_m2),
    sum(expected),
    tolerance = 1e-6
  )
})

test_that("grid_city_shares() gives shares over all prefectures", {
  helpers <- pipeline_helpers()
  areas <- fake_grid_city_areas()
  data <- helpers$grid_city_shares(rbind(areas[1, ], areas[-1, ]))

  expect_named(data, c("grid_code", "city_code", "area_m2", "share"))
  expect_equal(data$grid_code, areas$grid_code)
  expect_equal(data$share, c(0.25, 0.75, 1, 1))
})

test_that("grid_city_pipeline() has targets per release and size", {
  helpers <- pipeline_helpers()
  targets <- helpers$grid_city_pipeline()
  names <- vapply(targets, \(target) target$settings$name, character(1))
  n_releases <- length(unique(grid_city_files()$boundary_date))

  expect_length(names, n_releases * (2 + 2 * length(grid_sizes())))
  expect_contains(
    names,
    c(
      "grid_city_20200101_files",
      "grid_city_20200101_cities",
      "grid_city_20200101_250m_areas",
      "grid_city_20200101_250m"
    )
  )
  cities <- targets[[which(names == "grid_city_20200101_cities")]]
  expect_equal(
    cities$settings$pattern[[1]],
    quote(map(grid_city_20200101_files))
  )
})
