# Helpers of the crosswalk of grid squares to municipalities, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the crosswalk: one per file of `grid_city_files()`, that is per
# release and prefecture, and two per release that bind its prefectures into
# 500 m and 1 km squares. The URL is part of the command, so a replaced file
# rebuilds that file and its release only.
grid_city_pipeline <- function() {
  files <- locationchoicedatajp::grid_city_files()
  names <- locationchoicedatajp::grid_city_target_name(files$file_name)
  prefectures <- tarchetypes::tar_eval(
    targets::tar_target(name, grid_city_build(file_name, url)),
    values = list(
      name = rlang::syms(names),
      file_name = files$file_name,
      url = files$url
    )
  )
  groups <- split(names, files$boundary_date)
  releases <- Map(grid_city_release_targets, as.list(names(groups)), groups)
  list(prefectures, unlist(releases, recursive = FALSE, use.names = FALSE))
}

# The targets of a release, from the names of the targets of its prefectures.
grid_city_release_targets <- function(boundary_date, prefectures) {
  boundary_date <- as.Date(boundary_date)
  name_500m <- locationchoicedatajp::grid_city_release_target_name(
    boundary_date,
    "500m"
  )
  name_1km <- locationchoicedatajp::grid_city_release_target_name(
    boundary_date,
    "1km"
  )
  list(
    targets::tar_target_raw(
      name_500m,
      rlang::call2("grid_city_combine", !!!rlang::syms(prefectures))
    ),
    targets::tar_target_raw(
      name_1km,
      rlang::call2("grid_city_coarsen", rlang::sym(name_500m))
    )
  )
}

# Crosswalk of a release from its prefectures. Shares are computed after
# binding the prefectures, as squares straddle their borders.
grid_city_combine <- function(...) {
  grid_city_shares(dplyr::bind_rows(...))
}

# Crosswalk of 1 km squares from that of 500 m squares. The code of a 1 km
# square is the first eight digits of the codes of its four 500 m squares.
grid_city_coarsen <- function(data) {
  data$grid_code <- substr(data$grid_code, 1, 8)
  grid_city_shares(data)
}

# Land area of each grid square in each municipality, with its share.
grid_city_shares <- function(areas) {
  areas |>
    dplyr::summarise(area_m2 = sum(area_m2), .by = c(grid_code, city_code)) |>
    dplyr::mutate(share = area_m2 / sum(area_m2), .by = grid_code) |>
    dplyr::arrange(grid_code, city_code)
}

# Land area of each 500 m grid square in each municipality of a file. `url` is
# unused: it is an argument so that the URL is part of the command.
grid_city_build <- function(file_name, url) {
  # The terms of use are shown by `grid_city_get()`, not again by ksjdata in
  # the process of each target.
  rlang::local_options(rlib_message_verbosity = "quiet")
  layer <- ksjdata::ksj_get(file_name, col_names = "raw")
  grid_city_areas(layer)
}

# The polygons of the file are dissolved by municipality and cut by the grid
# squares that they touch. The cutting is planar in longitude and latitude, in
# which the squares are rectangles, and the areas are computed in an equal-area
# projection on the GRS80 ellipsoid. Files without a `.prj` file are in
# JGD2000, the datum of the catalog for them.
grid_city_areas <- function(layer) {
  old <- suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(old)), add = TRUE)
  if (is.na(sf::st_crs(layer))) {
    sf::st_crs(layer) <- 4612
  }

  # sf and jpgrid tell that longitude and latitude are treated as planar, which
  # is intended here.
  suppressMessages(suppressWarnings({
    cities <- layer |>
      dplyr::group_by(city_code = N03_007) |>
      dplyr::summarise(.groups = "drop") |>
      sf::st_make_valid()
    grids <- jpgrid::geometry_to_grid(cities, "500m")
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
