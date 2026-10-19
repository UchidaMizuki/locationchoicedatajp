# Environment with the helpers shared by the bundled pipelines.
pipeline_helpers <- function() {
  env <- new.env()
  tarchives::tar_source_archive("locationchoicedatajp", envir = env)
  env
}

# Sites of land prices in the layout of a release before 2024, where the use
# is in `L01_001`, the serial number in `L01_002`, the price in `L01_006`, and
# the municipality in `L01_017`, without a coordinate reference system.
fake_land_price_layer <- function(crs = sf::NA_crs_) {
  data <- tibble::tibble(
    L01_001 = c("000", "005"),
    L01_002 = c("001", "002"),
    L01_006 = c("100", "1000"),
    L01_017 = c("13101", "01101")
  )
  points <- list(sf::st_point(c(139.7, 35.7)), sf::st_point(c(141.3, 43.1)))
  sf::st_sf(data, geometry = sf::st_sfc(points, crs = crs))
}

fake_land_price_columns <- function() {
  c(
    city_code = "L01_017",
    use_code = "L01_001",
    site_number = "L01_002",
    price = "L01_006"
  )
}

# Two municipalities inside two 500 m grid squares, `533945092` and
# `533946001`, split inside the first square, without a coordinate reference
# system.
fake_city_layer <- function() {
  box <- function(xmin, xmax) {
    ymin <- 35.667
    ymax <- 35.6705
    sf::st_polygon(list(rbind(
      c(xmin, ymin),
      c(xmax, ymin),
      c(xmax, ymax),
      c(xmin, ymax),
      c(xmin, ymin)
    )))
  }
  sf::st_sf(
    N03_007 = c("13101", "13102"),
    geometry = sf::st_sfc(
      box(139.744, 139.747),
      box(139.747, 139.756)
    )
  )
}

# Areas of grid squares as stored by the pipeline: a 500 m square in two
# municipalities, one in a single municipality of the same 1 km square, and
# one with undetermined land.
fake_grid_city_areas <- function() {
  tibble::tibble(
    grid_code = c("533945092", "533945092", "533945093", "533945094"),
    city_code = c("13101", "13102", "13102", NA),
    area_m2 = c(100, 300, 400, 200)
  )
}

# A file of the census grid statistics in Shift_JIS, as published: the codes of
# the columns, their names, and the rows.
local_census_grid_file <- function(lines, env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".txt", .local_envir = env)
  con <- file(path, open = "w", encoding = "CP932")
  writeLines(lines, con)
  close(con)
  path
}

# A 500 m table of 2020 with a suppressed square merged into another.
fake_census_grid_lines <- function() {
  c(
    "KEY_CODE,HTKSYORI,HTKSAKI,GASSAN,T001141001,T001141034",
    ",,,,　人口（総数）,　世帯総数",
    "533900054,0,,,52,20",
    "533900064,2,533900073,,3,*",
    "533900073,1,,533900064,40,15"
  )
}

# Cells of the commuting table as collected for two origins of a prefecture,
# `13101` and `13102`, with a third municipality, `13103`, as a destination, and
# the total of the prefecture (`13000`) among the destinations.
fake_census_commuting_cells <- function() {
  tibble::tribble(
    ~origin_city_code , ~sex_code , ~place_code , ~destination_city_code , ~value ,
    "13101"           , "1"       , "011"       , "00000"                , "5"    ,
    "13101"           , "1"       , "012"       , "00000"                , "20"   ,
    "13101"           , "1"       , "02"        , "13101"                , "2"    ,
    "13101"           , "1"       , "02"        , "13102"                , "30"   ,
    "13101"           , "1"       , "02"        , "13103"                , "-"    ,
    "13101"           , "1"       , "024"       , "00000"                , "2"    ,
    "13101"           , "1"       , "03"        , "00000"                , "1"    ,
    "13102"           , "2"       , "011"       , "00000"                , "1"    ,
    "13102"           , "2"       , "012"       , "00000"                , "4"    ,
    "13102"           , "2"       , "02"        , "13101"                , "6"    ,
    "13102"           , "2"       , "02"        , "13102"                , "-"    ,
    "13102"           , "2"       , "02"        , "13103"                , "3"    ,
    "13102"           , "2"       , "024"       , "00000"                , "-"    ,
    "13102"           , "2"       , "03"        , "00000"                , "2"
  )
}
