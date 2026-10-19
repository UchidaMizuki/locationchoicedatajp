test_that("grid_sizes() lists sizes that nest, from the coarsest", {
  codes <- vapply(
    grid_sizes(),
    \(size) {
      as.character(jpgrid::coords_to_grid(139.7, 35.69, size))
    },
    character(1)
  )

  expect_equal(unname(nchar(codes)), c(8L, 9L, 10L))
  expect_equal(substr(codes[["500m"]], 1, 8), codes[["1km"]])
  expect_equal(substr(codes[["250m"]], 1, 9), codes[["500m"]])
})
