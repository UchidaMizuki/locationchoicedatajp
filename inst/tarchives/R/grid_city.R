# Helpers of the crosswalk of grid squares to municipalities, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the crosswalk, for each release of `grid_city_files()`:
#
# * `<release>_files`: its files by prefecture, with their URLs.
# * `<release>_cities`: the polygons of each file dissolved by municipality,
#   one dynamic branch per file. They do not depend on the size of the grid
#   squares, so they are built once.
# * `<release>_<size>_areas`: the land area of each grid square of a size in
#   each municipality, one dynamic branch per file.
# * `<release>_<size>`: the crosswalk of the release in squares of that size.
#
# Adding a size adds its targets without rebuilding the others, and a replaced
# file rebuilds only its branches, as branches are named by their data.
grid_city_pipeline <- function() {
  files <- locationchoicedatajp::grid_city_files()
  sizes <- locationchoicedatajp::grid_sizes()
  releases <- split(files, files$boundary_date)
  targets <- lapply(releases, \(files) grid_city_release_targets(files, sizes))
  unlist(targets, recursive = FALSE, use.names = FALSE)
}

grid_city_release_targets <- function(files, sizes) {
  boundary_date <- files$boundary_date[[1]]
  prefix <- paste0("grid_city_", format(boundary_date, "%Y%m%d"))
  files_name <- paste0(prefix, "_files")
  cities_name <- paste0(prefix, "_cities")

  release <- list(
    targets::tar_target_raw(
      files_name,
      rlang::expr(tibble::tibble(
        file_name = !!files$file_name,
        url = !!files$url
      ))
    ),
    targets::tar_target_raw(
      cities_name,
      rlang::expr(grid_city_build(!!rlang::sym(files_name))),
      pattern = rlang::expr(map(!!rlang::sym(files_name))),
      iteration = "list"
    )
  )
  by_size <- lapply(sizes, \(size) {
    size_name <- locationchoicedatajp::grid_city_release_target_name(
      boundary_date,
      size
    )
    areas_name <- paste0(size_name, "_areas")
    list(
      targets::tar_target_raw(
        areas_name,
        rlang::expr(grid_city_areas(!!rlang::sym(cities_name), !!size)),
        pattern = rlang::expr(map(!!rlang::sym(cities_name)))
      ),
      targets::tar_target_raw(
        size_name,
        rlang::expr(grid_city_shares(!!rlang::sym(areas_name)))
      )
    )
  })
  c(release, unlist(by_size, recursive = FALSE))
}

# Polygons of a file (a row of `<release>_files`) dissolved by municipality.
# Files without a `.prj` file are in JGD2000, the datum of the catalog for
# them. The URL is in the row, so that a replaced file rebuilds its branch.
grid_city_build <- function(file) {
  # The terms of use are shown by `grid_city_get()`, not again by ksjdata in
  # the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  layer <- ksjdata::ksj_get(file$file_name, col_names = "raw")
  if (is.na(sf::st_crs(layer))) {
    sf::st_crs(layer) <- 4612
  }
  grid_city_dissolve(layer)
}

grid_city_dissolve <- function(layer) {
  old <- suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(old)), add = TRUE)
  # sf tells that longitude and latitude are treated as planar, which is
  # intended here.
  suppressMessages(
    layer |>
      dplyr::group_by(city_code = N03_007) |>
      dplyr::summarise(.groups = "drop") |>
      sf::st_make_valid()
  )
}

# Land area of each grid square of a size in each municipality. The polygons
# are cut by the squares that they touch. The cutting is planar in longitude
# and latitude, in which the squares are rectangles, and the areas are computed
# in an equal-area projection on the GRS80 ellipsoid.
grid_city_areas <- function(cities, grid_size) {
  old <- suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(old)), add = TRUE)
  # sf and jpgrid tell that longitude and latitude are treated as planar, which
  # is intended here.
  suppressMessages(suppressWarnings({
    grids <- jpgrid::geometry_to_grid(cities, grid_size)
    cells <- jpgrid::grid_as_sf(
      unique(do.call(c, grids)),
      crs = sf::st_crs(cities)
    )
    sf::st_agr(cells) <- "constant"
    sf::st_agr(cities) <- "constant"
    pieces <- sf::st_intersection(cells, cities)
  }))

  equal_area <- "+proj=aea +lat_0=36 +lon_0=136 +lat_1=25 +lat_2=47 +ellps=GRS80 +units=m"
  areas <- tibble::tibble(
    grid_code = as.character(pieces$grid),
    city_code = pieces$city_code,
    area_m2 = as.numeric(sf::st_area(sf::st_transform(pieces, equal_area)))
  )
  # Squares that only touch a municipality give pieces without area.
  areas[areas$area_m2 > 0, ]
}

# Crosswalk of a release from the areas of its prefectures, with the share of
# each square. Shares are computed after binding the prefectures, as squares
# straddle their borders.
grid_city_shares <- function(areas) {
  areas |>
    dplyr::summarise(area_m2 = sum(area_m2), .by = c(grid_code, city_code)) |>
    dplyr::mutate(share = area_m2 / sum(area_m2), .by = grid_code) |>
    dplyr::arrange(grid_code, city_code)
}
