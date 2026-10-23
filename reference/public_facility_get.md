# Get municipal offices and public meeting facilities

Returns the municipal offices and public meeting facilities of National
Land Numerical Information (市町村役場等及び公的集会施設, P05) in a
year, one row per facility, as published. The first call for a year
downloads the file of that year's release (via ksjdata) and builds the
table, which is then cached.

## Usage

``` r
public_facility_get(year)
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 市町村役場等及び公的集会施設データ (P05):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P05-2022.html>. See
[`data_sources()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/data_sources.md)
for the terms of use.

## Arguments

- year:

  Reference year (fiscal year). See
  [`public_facility_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/public_facility_files.md)
  for the available years. The release of 2010 is left out, as it may
  not be used commercially.

## Value

An `sf` tibble with one row per facility:

- `year`, `release`: The reference year and the year of its release,
  which is `year`.

- `city_code`: 行政区域コード (P05_001) of the municipality, as
  published.

- `facility_type_code`: 施設分類 (P05_002): `"1"` 本庁 (the office of a
  municipality or a ward), `"2"` 支所、出張所、連絡所, `"3"` other
  facilities with administrative services, `"4"` 公立公民館, `"5"` other
  public meeting facilities (集会施設).

- `facility_name`, `address`: 名称 and 所在地, as published.

- `geometry`: The facility as a point, in JGD2011 (EPSG:6668).

## Details

The file has a layer per prefecture in the same layout, which are bound.
The offices (`facility_type_code` `"1"`) are those of municipalities and
of the wards of designated cities; the office of a designated city has
the code of the ward it is in. Codes are kept as published, including a
few that are not of the municipality of the facility.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 市町村役場等及び公的集会施設データ, by the Ministry of
Land, Infrastructure, Transport and Tourism), and processed data must
say that they were processed.

## See also

[`public_facility_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/public_facility_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
public_facility_get(2022)
}
```
