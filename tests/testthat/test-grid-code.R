test_that("grid_code() gives the code of the grid square of points", {
  points <- sf::st_sfc(
    sf::st_point(c(139.7, 35.69)),
    sf::st_point(c(135.5, 34.69)),
    crs = 6668
  )

  expect_equal(grid_code(points, "500m"), c("533945254", "523503294"))
  expect_equal(grid_code(points, "1km"), c("53394525", "52350329"))
})

test_that("grid_code() errors on geometries other than points", {
  polygon <- sf::st_sfc(
    sf::st_polygon(list(rbind(c(0, 0), c(1, 0), c(1, 1), c(0, 0)))),
    crs = 6668
  )
  projected <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 2451)

  expect_snapshot(error = TRUE, {
    grid_code(polygon, "500m")
    grid_code(projected, "500m")
  })
})

test_that("grid_code() needs a size of grid_sizes()", {
  points <- sf::st_sfc(sf::st_point(c(139.7, 35.69)), crs = 6668)

  expect_snapshot(error = TRUE, {
    grid_code(points)
    grid_code(points, "10km")
  })
})
