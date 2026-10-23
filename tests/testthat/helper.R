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

# Stations of a release before 2022, without codes and a coordinate reference
# system.
fake_rail_station_layer <- function(crs = sf::NA_crs_) {
  data <- tibble::tibble(
    N02_001 = "11",
    N02_002 = "2",
    N02_003 = "山手線",
    N02_004 = "東日本旅客鉄道",
    N02_005 = "東京"
  )
  line <- sf::st_linestring(rbind(c(139.766, 35.681), c(139.767, 35.682)))
  sf::st_sf(data, geometry = sf::st_sfc(line, crs = crs))
}

# A school in the layout of the release of 2021, which stores some codes as
# numbers and has no campus code.
fake_school_layer <- function(crs = 6668) {
  data <- tibble::tibble(
    P29_001 = "13101",
    P29_002 = "B113210100016",
    P29_003 = 16001L,
    P29_004 = "千代田区立麹町小学校",
    P29_005 = "麹町2-8",
    P29_006 = 3L,
    P29_007 = 1L
  )
  point <- sf::st_point(c(139.74, 35.68))
  sf::st_sf(data, geometry = sf::st_sfc(point, crs = crs))
}

# A hospital in the layout of the release of 2020, which stores the codes as
# numbers.
fake_medical_institution_layer <- function(crs = 6668) {
  data <- tibble::tibble(
    P04_001 = 1L,
    P04_002 = "東京病院",
    P04_003 = "東京都千代田区1-1",
    P04_004 = "内　外",
    P04_005 = NA_character_,
    P04_006 = NA_character_,
    P04_007 = 2L,
    P04_008 = 100L,
    P04_009 = 1L,
    P04_010 = 9L
  )
  point <- sf::st_point(c(139.76, 35.69))
  sf::st_sf(data, geometry = sf::st_sfc(point, crs = crs))
}

# A section of a line in the layout of a release until 2014, without a
# coordinate reference system.
fake_rail_line_layer <- function(crs = sf::NA_crs_) {
  data <- tibble::tibble(
    N02_001 = "11",
    N02_002 = "2",
    N02_003 = "山手線",
    N02_004 = "東日本旅客鉄道"
  )
  line <- sf::st_linestring(rbind(c(139.766, 35.681), c(139.770, 35.690)))
  sf::st_sf(data, geometry = sf::st_sfc(line, crs = crs))
}

# Shows the terms of the source of a getter again, as they are shown once per
# session and source, and getters can share a source.
reset_terms <- function(function_name) {
  sources <- data_sources()
  source_name <- sources$source_name[sources$function_name == function_name]
  rlang::reset_message_verbosity(
    paste0("locationchoicedatajp_terms_", source_name)
  )
}

# A municipal office in the layout of the release of 2022.
fake_public_facility_layer <- function(crs = 6668) {
  data <- tibble::tibble(
    P05_001 = "13101",
    P05_002 = "1",
    P05_003 = "千代田区役所",
    P05_004 = "九段南1-2-1"
  )
  point <- sf::st_point(c(139.75, 35.69))
  sf::st_sf(data, geometry = sf::st_sfc(point, crs = crs))
}
