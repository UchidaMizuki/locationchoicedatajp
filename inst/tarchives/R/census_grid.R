# Helpers of the grid square statistics of the Population Census, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of each table of `census_grid_tables()`:
#
# * `<table>_primary_grids`: the primary grid squares in which it is
#   downloaded.
# * `<table>_files`: the rows of each primary grid square, one dynamic branch
#   per square.
# * `<table>`: the table, read by `census_grid_get()`.
census_grid_pipeline <- function() {
  tables <- locationchoicedatajp::census_grid_tables()
  items <- locationchoicedatajp::census_grid_items()
  primary_grids <- locationchoicedatajp::census_grid_primary_grids()
  targets <- lapply(seq_len(nrow(tables)), \(i) {
    stats_id <- tables$stats_id[[i]]
    census_grid_table_targets(
      stats_id,
      tables$grid_size[[i]],
      items$item_code[items$stats_id == stats_id],
      primary_grids
    )
  })
  unlist(targets, recursive = FALSE)
}

census_grid_table_targets <- function(
  stats_id,
  grid_size,
  item_codes,
  primary_grids
) {
  name <- locationchoicedatajp::census_grid_target_name(stats_id)
  grids_name <- paste0(name, "_primary_grids")
  files_name <- paste0(name, "_files")
  list(
    targets::tar_target_raw(grids_name, rlang::expr(c(!!!primary_grids))),
    targets::tar_target_raw(
      files_name,
      rlang::expr(census_grid_build(
        !!stats_id,
        !!rlang::sym(grids_name),
        !!grid_size,
        !!item_codes
      )),
      pattern = rlang::expr(map(!!rlang::sym(grids_name)))
    ),
    targets::tar_target_raw(
      name,
      rlang::expr(dplyr::arrange(!!rlang::sym(files_name), grid_code))
    )
  )
}

census_grid_url <- function(stats_id, primary_grid) {
  paste0(
    "https://www.e-stat.go.jp/gis/statmap-search/data?statsId=",
    stats_id,
    "&code=",
    primary_grid,
    "&downloadType=2"
  )
}

# Rows of a table in a primary grid square. e-Stat answers 404 for a square
# without residents, which has no rows.
census_grid_build <- function(stats_id, primary_grid, grid_size, item_codes) {
  dir <- fs::dir_create(fs::file_temp("census-grid"))
  on.exit(fs::dir_delete(dir), add = TRUE)
  archive <- fs::path(dir, "archive.zip")
  url <- census_grid_url(stats_id, primary_grid)
  if (!census_grid_download(url, archive)) {
    return(census_grid_read(NULL, grid_size, item_codes))
  }
  file <- utils::unzip(archive, exdir = dir)
  census_grid_check(length(file) == 1, "archives")
  census_grid_read(file, grid_size, item_codes)
}

# Downloads an archive, and returns whether there is one (`FALSE` for 404).
# e-Stat sometimes answers a run of requests with a page or a broken archive,
# so the download is retried until it is an archive of one file.
census_grid_download <- function(url, path, attempts = 3) {
  for (attempt in seq_len(attempts)) {
    response <- curl::curl_fetch_disk(url, path)
    if (response$status_code == 404) {
      return(FALSE)
    }
    if (response$status_code == 200 && census_grid_is_archive(path)) {
      return(TRUE)
    }
    Sys.sleep(10 * attempt)
  }
  rlang::abort(
    sprintf("Downloading %s failed: %d.", url, response$status_code),
    class = "locationchoicedatajp_error_download"
  )
}

census_grid_is_archive <- function(path) {
  files <- tryCatch(
    utils::unzip(path, list = TRUE),
    error = function(e) NULL,
    warning = function(w) NULL
  )
  !is.null(files) && nrow(files) == 1
}

# Reads a file of the table: comma-separated in Shift_JIS, with the codes of the
# columns on the first line and their names on the second. Suppressed values
# (`*`) are `NA`. The columns must be those of the definition of the table.
census_grid_read <- function(file, grid_size, item_codes) {
  if (is.null(file)) {
    data <- as.data.frame(
      rep(list(character()), length(item_codes) + 4),
      col.names = c("KEY_CODE", "HTKSYORI", "HTKSAKI", "GASSAN", item_codes)
    )
  } else {
    columns <- strsplit(readLines(file, n = 1, encoding = "latin1"), ",")[[1]]
    data <- utils::read.csv(
      file,
      header = FALSE,
      skip = 2,
      col.names = columns,
      colClasses = "character",
      na.strings = c("", "*"),
      fileEncoding = "CP932"
    )
  }
  census_grid_check(
    identical(
      setdiff(names(data), c("HTKSYORI", "HTKSAKI", "GASSAN")),
      c("KEY_CODE", item_codes)
    ),
    "columns"
  )

  digits <- c("1km" = 8, "500m" = 9, "250m" = 10)[[grid_size]]
  census_grid_check(nchar(data$KEY_CODE) == digits, "grid codes")
  values <- lapply(data[item_codes], as.integer)
  census_grid_check(
    !is.na(unlist(values)) | is.na(unlist(data[item_codes])),
    "values"
  )

  # The tables of 2010 have no suppression.
  if (is.null(data$HTKSYORI)) {
    data$HTKSYORI <- data$HTKSAKI <- rep(NA_character_, nrow(data))
  }
  tibble::tibble(
    grid_code = data$KEY_CODE,
    suppression_code = data$HTKSYORI,
    merged_into_grid_code = data$HTKSAKI,
    !!!values
  )
}

census_grid_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the file are not as expected.", what),
      class = "locationchoicedatajp_error_census_grid"
    )
  }
}
