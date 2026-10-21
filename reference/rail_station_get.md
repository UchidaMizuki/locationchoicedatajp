# Get railway stations

Returns the railway stations of National Land Numerical Information
(鉄道, N02) in a year, one row per station of a line, as published. The
first call for a year downloads the file of that year's release (via
ksjdata) and builds the table, which is then cached.

## Usage

``` r
rail_station_get(year)
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 鉄道データ (N02):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N02-2025.html>. See
[`data_sources()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/data_sources.md)
for the terms of use.

## Arguments

- year:

  Reference year: 2006 to 2008, and 2011 to the latest release. Releases
  are as of December 31 of their year. See
  [`rail_station_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_station_files.md)
  for the available years.

## Value

An `sf` tibble with one row per station of a line:

- `year`, `release`: The reference year and the year of its release,
  which is `year`.

- `railway_type_code`: 鉄道区分 (N02_001), as published.

- `operator_type_code`: 事業者種別 (N02_002), as published.

- `line_name`, `operator_name`, `station_name`: 路線名, 運営会社, and
  駅名, as published.

- `station_code`, `station_group_code`: 駅コード and グループコード,
  published from 2022 and `NA` before. A group is the stations of the
  same name within 300 m.

- `geometry`: The station as a line, in the coordinate reference system
  of the release: JGD2011 (EPSG:6668) from 2015. The files until 2014
  have no `.prj` file, and are set to JGD2000 (EPSG:4612), the datum of
  the catalog.

## Details

A station served by several lines has a row for each line. Stations are
lines (the extent of their platforms) as published; take a point of them
or group them by `station_group_code` as the model needs.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 鉄道データ, by the Ministry of Land, Infrastructure,
Transport and Tourism), and processed data must say that they were
processed.

## See also

[`rail_station_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_station_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
rail_station_get(2020)
}
```
