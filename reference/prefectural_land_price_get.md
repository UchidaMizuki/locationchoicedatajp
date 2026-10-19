# Get prefectural land prices

Returns the sites of the prefectural land price survey
(都道府県地価調査) of National Land Numerical Information in a year, one
row per site, as published. The first call for a year downloads the file
of that year's release (via ksjdata) and builds the table, which is then
cached.

## Usage

``` r
prefectural_land_price_get(year)
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 都道府県地価調査データ (L02):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L02-2026.html>. The
terms of use are on
<https://nlftp.mlit.go.jp/ksj/other/agreement_01.html>.

## Arguments

- year:

  Reference year, from 2006 to the latest release. See
  [`prefectural_land_price_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/prefectural_land_price_files.md)
  for the available years. To get several years, iterate over them: the
  coordinate reference system differs between releases.

## Value

An `sf` tibble with one row per site, with the columns of
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md):

- `year`, `release`: The reference year (prices are as of July 1) and
  the year of the release, which is `year`.

- `city_code`: Five-digit municipality code, as published for that year.

- `use_code`: Three-digit use of the site (用途区分), as published:
  `000` 住宅地, `003` 宅地見込地, `005` 商業地, `009` 工業地, and `020`
  林地, and, until 2012, also `007` and `010`.

- `site_number`: Three-digit serial number of the site within its
  municipality and use, as published.

- `price_jpy_per_m2`: The price in yen per square meter. Forest land
  (`020`) is published in yen per 10 ares, and is divided by 1,000. One
  site in 2008 has a price of 0, as published.

- `geometry`: The point of the site, in the coordinate reference system
  of the release: JGD2000 (EPSG:4612) until 2022 and JGD2011 (EPSG:6668)
  from 2023. The files until 2012 have no `.prj` file, and are set to
  JGD2000.

## Details

The survey is a separate source from the official land prices of
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md)
(地価公示): its prices are as of July 1, not January 1, and its sites
are chosen by the prefectures. The year is taken from its own release,
and the sites are not summarised.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 都道府県地価調査データ, by the Ministry of Land,
Infrastructure, Transport and Tourism), and processed data must say that
they were processed.

## See also

[`prefectural_land_price_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/prefectural_land_price_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
prefectural_land_price_get(2020)
}
```
