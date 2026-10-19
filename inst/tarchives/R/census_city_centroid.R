# Helpers of the population centroids of municipalities, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of the centroids: one per year of `census_city_centroid_files()`.
census_city_centroid_pipeline <- function() {
  files <- locationchoicedatajp::census_city_centroid_files()
  names <- locationchoicedatajp::census_city_centroid_target_name(files$year)
  tarchetypes::tar_eval(
    targets::tar_target(name, census_city_centroid_build(year, url, angle)),
    values = list(
      name = rlang::syms(names),
      year = files$year,
      url = files$url,
      angle = files$angle
    )
  )
}

# Centroids of a year from the workbook of the Statistics Bureau, one sheet per
# prefecture (and one for the country in 2020).
census_city_centroid_build <- function(year, url, angle) {
  path <- fs::file_temp(ext = fs::path_ext(url))
  on.exit(fs::file_delete(path), add = TRUE)
  curl::curl_download(url, path, quiet = TRUE)
  sheets <- readxl::excel_sheets(path)
  rows <- lapply(sheets, \(sheet) {
    cells <- readxl::read_excel(
      path,
      sheet = sheet,
      col_names = FALSE,
      col_types = "text",
      .name_repair = "minimal"
    )
    census_city_centroid_rows(cells)
  })
  census_city_centroid_points(dplyr::bind_rows(rows), year, angle)
}

# Rows of a sheet: the code, name, longitude, and latitude of each area, below
# the two rows of headers. A note below the rows (`注）...`) is dropped.
census_city_centroid_rows <- function(cells) {
  cells <- cells[-(1:2), 1:4]
  rows <- tibble::tibble(
    city_code = cells[[1]],
    city_name = cells[[2]],
    longitude = cells[[3]],
    latitude = cells[[4]]
  )
  rows[!is.na(rows$city_code) & !startsWith(rows$city_code, "注"), ]
}

# Points of the municipalities, without the country (00000) and the prefectures
# (xx000), in JGD2000. Angles are in decimal degrees or as DDDMMSS.ss.
census_city_centroid_points <- function(rows, year, angle) {
  rows <- rows[!duplicated(rows), ]
  # Municipalities without residents have no centroid, which the workbook
  # marks with a note on their name.
  none <- is.na(rows$longitude) | is.na(rows$latitude)
  census_city_centroid_check(endsWith(rows$city_name[none], "注）"), "notes")
  rows <- rows[!none, ]
  census_city_centroid_check(
    grepl("^[0-9]{5}$", rows$city_code),
    "codes"
  )
  rows <- rows[substr(rows$city_code, 3, 5) != "000", ]
  census_city_centroid_check(!duplicated(rows$city_code), "codes")

  longitude <- census_city_centroid_angle(rows$longitude, angle)
  latitude <- census_city_centroid_angle(rows$latitude, angle)
  census_city_centroid_check(longitude > 122 & longitude < 154, "longitudes")
  census_city_centroid_check(latitude > 20 & latitude < 46, "latitudes")

  points <- sf::st_as_sf(
    tibble::tibble(
      year = year,
      release = year,
      city_code = rows$city_code,
      longitude = longitude,
      latitude = latitude
    ),
    coords = c("longitude", "latitude"),
    crs = 4612
  )
  points[order(points$city_code), ]
}

census_city_centroid_angle <- function(x, angle) {
  x <- as.numeric(x)
  if (angle == "decimal") {
    return(x)
  }
  # DDDMMSS.ss
  degrees <- x %/% 10000
  minutes <- (x %/% 100) %% 100
  seconds <- x %% 100
  degrees + minutes / 60 + seconds / 3600
}

census_city_centroid_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the centroids are not as expected.", what),
      class = "locationchoicedatajp_error_census_city_centroid"
    )
  }
}
