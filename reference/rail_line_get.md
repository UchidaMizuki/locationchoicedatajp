# Get railway lines

Returns the railway lines of National Land Numerical Information (鉄道,
N02) in a year, one row per section of a line, as published. The first
call for a year downloads the file of that year's release (via ksjdata)
and builds the table, which is then cached.

## Usage

``` r
rail_line_get(year)
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
  [`rail_line_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_line_files.md)
  for the available years.

## Value

An `sf` tibble with one row per section of a line:

- `year`, `release`: The reference year and the year of its release,
  which is `year`.

- `railway_type_code`: 鉄道区分 (N02_001): `"11"` 普通鉄道JR, `"12"`
  普通鉄道, `"13"` 鋼索鉄道, `"14"` 懸垂式鉄道, `"15"` 跨座式鉄道,
  `"16"` 案内軌条式鉄道, `"17"` 無軌条鉄道, `"21"` 軌道, `"22"`
  懸垂式モノレール, `"23"` 跨座式モノレール, `"24"` 案内軌条式, `"25"`
  浮上式.

- `operator_type_code`: 事業者種別 (N02_002): `"1"` JRの新幹線, `"2"`
  JR在来線, `"3"` 公営鉄道, `"4"` 民営鉄道, `"5"` 第三セクター.

- `line_name`, `operator_name`: 路線名 and 運営会社, as published.

- `geometry`: The section as a line, in the coordinate reference system
  of the release: JGD2011 (EPSG:6668) from 2015. The files until 2014
  have no `.prj` file, and are set to JGD2000 (EPSG:4612), the datum of
  the catalog.

## Details

A line is published as sections, and a track shared by several lines has
a section for each line. The stations of the same files are
[`rail_station_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_station_get.md).

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 鉄道データ, by the Ministry of Land, Infrastructure,
Transport and Tourism), and processed data must say that they were
processed.

## See also

[`rail_line_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_line_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
rail_line_get(2020)
}
```
