# Get commuting flows of the Population Census

Returns the flows of residents by place of work or school
(従業地・通学地) between municipalities, from the Population Census, one
row per origin, destination, place, and sex, as published. The first
call for a year and purpose downloads the table from the e-Stat API and
builds it, which is then cached. The download needs an e-Stat API key in
the environment variable `ESTAT_API_KEY` (see the jpstat package).

## Usage

``` r
census_commuting_get(year, purpose)
```

## Source

Statistics Bureau of Japan, Population Census of 2020, table 0003454524
(男女，就業・通学，従業地・通学地別就業者・通学者数) on e-Stat:
<https://www.e-stat.go.jp/dbview?sid=0003454524>. The terms of use of
e-Stat, based on the Standard Terms of Use of the Government of Japan
(Version 2.0) and compatible with CC BY 4.0, are on
<https://www.e-stat.go.jp/terms-of-use>.

## Arguments

- year:

  The year of the census: 2020. Earlier censuses publish their flows in
  other layouts, and are planned.

- purpose:

  The purpose of the trip: `"work"` for employed persons aged 15 and
  over (15歳以上就業者) or `"school"` for students aged 15 and over
  (15歳以上通学者). There is no default, as the purpose is a choice of
  the model.

## Value

A tibble with one row per origin, destination, place, and sex:

- `year`: The year of the census (integer), as of October 1.

- `release`: The year of the release the values are taken from
  (integer). It is `year`.

- `origin_city_code`: Five-digit code of the municipality of residence,
  as published for that year. Designated cities are split into wards.

- `destination_city_code`: Five-digit code of the municipality of work
  or school, or `NA` if it is unknown or abroad.

- `place_code`: The place of work or school (従業地・通学地), as
  published: `011` at home (自宅で従業), `012` outside the home in the
  municipality of residence (自宅外の自市区町村で従業・通学), `02` in
  another municipality (他市区町村で従業・通学), `024` in a municipality
  that is unknown or abroad (従業・通学市区町村「不詳・外国」), and `03`
  unknown (従業地・通学地「不詳」).

- `sex_code`: `1` male and `2` female, as published.

- `flow`: The number of persons (integer).

The flows of each municipality of residence sum to its published number
of employed persons or students.

## Details

Flows within the municipality of residence are split into those working
at home (`place_code` `011`) and outside the home (`012`), so that
models can keep or drop work at home. Flows to unknown places are kept,
without a destination. Zero flows between municipalities are kept, so
that every origin has a row for every destination.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (the Population Census by the
Statistics Bureau of Japan, from e-Stat), and processed data must say
that they were processed.

## See also

[`census_commuting_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_commuting_target.md)
to declare the table as a target, and
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md)
to link municipalities to grid squares.

## Examples

``` r
if (FALSE) { # interactive() && nzchar(Sys.getenv("ESTAT_API_KEY"))
flows <- census_commuting_get(2020, "work")

# Flows outside the home, summed over sex
flows |>
  dplyr::filter(place_code != "011", !is.na(destination_city_code)) |>
  dplyr::summarise(
    flow = sum(flow),
    .by = c(origin_city_code, destination_city_code)
  )
}
```
