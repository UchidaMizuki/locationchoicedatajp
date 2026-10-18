# Get land prices

Returns the sites of the official land prices (地価公示) of National
Land Numerical Information in a year, one row per site, as published.
The first call for a year downloads the file of that year's release (via
ksjdata) and builds the table, which is then cached.

## Usage

``` r
land_price_get(year)
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 地価公示データ (L01):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L01-2026.html>. The
terms of use are on
<https://nlftp.mlit.go.jp/ksj/other/agreement_01.html>.

## Arguments

- year:

  Reference year, from 2007 to the latest release. See
  [`land_price_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_files.md)
  for the available years. To get several years, iterate over them, for
  example with
  [`purrr::map()`](https://purrr.tidyverse.org/reference/map.html): the
  coordinate reference system differs between releases, so bind them
  after making it the same.

## Value

An `sf` tibble with one row per site:

- `year`: The reference year (integer). Prices are as of January 1.

- `release`: The year of the release the values are taken from
  (integer). It is `year`.

- `city_code`: Five-digit municipality code of the number of the site
  (標準地番号), as published for that year. Designated cities are split
  into wards.

- `use_code`: Three-digit use of the site (用途区分), as published. The
  codes are those of the code list of the latest release (`000` 住宅地,
  `003` 宅地見込地, `005` 商業地, `009` 工業地, `013` 林地) and, until
  2012, also `007` and `010`, which are not used from 2013. The files of
  2014 to 2016 have no sites of `003` or `013`. Compare uses across
  these breaks with care.

- `site_number`: Three-digit serial number of the site within its
  municipality and use, as published. `city_code`, `use_code`, and
  `site_number` identify a site within a year; numbers can change
  between years.

- `price_jpy_per_m2`: The price in yen per square meter.

- `geometry`: The point of the site, as published. Its coordinate
  reference system is that of the release: JGD2000 (EPSG:4612) until
  2023 and JGD2011 (EPSG:6668) from 2024. The files until 2017 have no
  `.prj` file, and are set to JGD2000, the datum of the catalog.

## Details

The year is taken from its own release, so it covers every site that was
surveyed in it, and its values do not change when a later release is
published. The sites are not summarised: summarise them by municipality,
by grid square, or by use as the analysis needs.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 地価公示データ, by the Ministry of Land, Infrastructure,
Transport and Tourism), and processed data must say that they were
processed.

## See also

[`land_price_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
sites <- land_price_get(2020)

# Median price of residential sites by municipality
sites |>
  sf::st_drop_geometry() |>
  dplyr::filter(use_code == "000") |>
  dplyr::summarise(price = median(price_jpy_per_m2), .by = city_code)
}
```
