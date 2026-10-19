# Helpers of the commuting flows of the Population Census, sourced by
# `tarchives::tar_source_archive("locationchoicedatajp")`.

# Targets of each row of `census_commuting_tables()`:
#
# * `<table>_prefectures`: the prefectures of the origins.
# * `<table>_origins`: the flows from the municipalities of each prefecture,
#   one dynamic branch per prefecture.
# * `<table>`: the flows, read by `census_commuting_get()`.
census_commuting_pipeline <- function() {
  tables <- locationchoicedatajp::census_commuting_tables()
  targets <- lapply(seq_len(nrow(tables)), \(i) {
    census_commuting_table_targets(
      locationchoicedatajp::census_commuting_target_name(
        tables$year[[i]],
        tables$purpose[[i]]
      ),
      tables$stats_data_id[[i]],
      tables$item_code[[i]]
    )
  })
  unlist(targets, recursive = FALSE)
}

census_commuting_table_targets <- function(name, stats_data_id, item_code) {
  prefectures_name <- paste0(name, "_prefectures")
  origins_name <- paste0(name, "_origins")
  list(
    targets::tar_target_raw(
      prefectures_name,
      rlang::expr(sprintf("%02d", 1:47))
    ),
    targets::tar_target_raw(
      origins_name,
      rlang::expr(census_commuting_build(
        !!stats_data_id,
        !!item_code,
        !!rlang::sym(prefectures_name)
      )),
      pattern = rlang::expr(map(!!rlang::sym(prefectures_name)))
    ),
    targets::tar_target_raw(
      name,
      rlang::expr(dplyr::arrange(
        !!rlang::sym(origins_name),
        origin_city_code,
        sex_code,
        place_code,
        destination_city_code
      ))
    )
  )
}

# Categories of the place of work or school (従業地・通学地) that make up the
# flows: at home (011) and outside the home (012) in the municipality of
# residence, in another municipality (02, by destination), in a municipality
# that is unknown or abroad (024), and unknown (03).
census_commuting_places <- c("011", "012", "02", "024", "03")

# Flows from the municipalities of a prefecture, by sex, from the e-Stat API.
# All destinations are requested, as the codes of the municipalities would make
# the URL too long; the totals among them are dropped by
# `census_commuting_flows()`. The flows of each municipality are checked to sum
# to its published total.
census_commuting_build <- function(stats_data_id, item_code, prefecture_code) {
  table <- jpstat::estat(stats_data_id)
  origins <- census_commuting_leaves(table, "area")
  origins <- origins[substr(origins, 1, 2) == prefecture_code]
  destinations <- census_commuting_leaves(table, "cat03")
  # The API takes at most 100 codes in a filter.
  chunks <- split(origins, ceiling(seq_along(origins) / 100))
  flows <- lapply(chunks, \(origins) {
    census_commuting_build_origins(table, item_code, origins, destinations)
  })
  dplyr::bind_rows(flows)
}

census_commuting_build_origins <- function(
  table,
  item_code,
  origins,
  destinations
) {
  flows <- table |>
    jpstat::activate("area") |>
    dplyr::filter(code %in% origins) |>
    jpstat::activate("cat01") |>
    dplyr::filter(code %in% c("1", "2")) |>
    jpstat::activate("cat02") |>
    dplyr::filter(code %in% census_commuting_places) |>
    jpstat::activate("cat04") |>
    dplyr::filter(code == item_code) |>
    census_commuting_collect()
  totals <- table |>
    jpstat::activate("area") |>
    dplyr::filter(code %in% origins) |>
    jpstat::activate("cat01") |>
    dplyr::filter(code == "0") |>
    jpstat::activate("cat02") |>
    dplyr::filter(code == "0") |>
    jpstat::activate("cat03") |>
    dplyr::filter(code == "00000") |>
    jpstat::activate("cat04") |>
    dplyr::filter(code == item_code) |>
    census_commuting_collect()

  flows <- census_commuting_flows(flows, destinations)
  census_commuting_check_totals(flows, totals)
  flows
}

# The municipalities of a dimension: codes that have no children, so that
# designated cities are split into wards, without the totals of the country and
# the prefectures.
census_commuting_leaves <- function(table, dimension) {
  meta <- table |>
    jpstat::activate(!!dimension) |>
    tibble::as_tibble()
  meta$code[!meta$code %in% meta$parentCode & meta$level != "1"]
}

census_commuting_collect <- function(table) {
  data <- suppressMessages(dplyr::collect(table, n = "value"))
  tibble::tibble(
    origin_city_code = data$area_code,
    sex_code = data$cat01_code,
    place_code = data$cat02_code,
    destination_city_code = data$cat03_code,
    value = data$value
  )
}

# Flows from the cells of the table. Counts written as `-` are zero. Flows
# within the municipality of residence and to unknown places have no
# destination in the table (`00000`): the destination of the former is the
# municipality of residence, and that of the latter is `NA`. Under another
# municipality (02), the code of the municipality of residence holds the flows
# to unknown municipalities or abroad, which are already in 024, so it is
# dropped, as are the totals among the destinations (prefectures and
# designated cities): only `destinations` are kept.
census_commuting_flows <- function(cells, destinations) {
  census_commuting_check(
    cells$value == "-" | grepl("^[0-9]+$", cells$value),
    "values"
  )
  cells$flow <- as.integer(ifelse(cells$value == "-", "0", cells$value))

  other <- cells$place_code == "02"
  destination <- cells$destination_city_code
  cells <- cells[
    (other &
      destination %in% destinations &
      destination != cells$origin_city_code) |
      (!other & destination == "00000"),
  ]
  within <- cells$place_code %in% c("011", "012")
  cells$destination_city_code[within] <- cells$origin_city_code[within]
  cells$destination_city_code[cells$place_code %in% c("024", "03")] <- NA

  cells[c(
    "origin_city_code",
    "destination_city_code",
    "place_code",
    "sex_code",
    "flow"
  )]
}

census_commuting_check_totals <- function(flows, totals) {
  sums <- tapply(flows$flow, flows$origin_city_code, sum)
  published <- stats::setNames(
    as.integer(ifelse(totals$value == "-", "0", totals$value)),
    totals$origin_city_code
  )
  census_commuting_check(
    setequal(names(sums), names(published)) &&
      all(sums[names(published)] == published),
    "totals"
  )
}

census_commuting_check <- function(ok, what) {
  if (anyNA(ok) || !all(ok)) {
    rlang::abort(
      sprintf("The %s of the commuting flows are not as expected.", what),
      class = "locationchoicedatajp_error_census_commuting"
    )
  }
}
