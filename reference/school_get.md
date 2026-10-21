# Get schools

Returns the schools of National Land Numerical Information (学校, P29)
in a year, one row per site, as published. The first call for a year
downloads the file of that year's release (via ksjdata) and builds the
table, which is then cached.

## Usage

``` r
school_get(year)
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 学校データ (P29):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P29-2023.html>. See
[`data_sources()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/data_sources.md)
for the terms of use.

## Arguments

- year:

  Reference year (school year). See
  [`school_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/school_files.md)
  for the available years. The release of 2013 is left out, as it may
  not be used commercially.

## Value

An `sf` tibble with one row per site:

- `year`, `release`: The reference year and the year of its release,
  which is `year`.

- `city_code`: 行政区域コード (P29_001) of the municipality, as
  published: designated cities are whole cities (for example `"14100"`)
  in 2021 and wards in 2023.

- `school_code`: 学校コード (P29_002), as published.

- `school_type_code`: 学校分類 (P29_003): `"16001"` 小学校, `"16002"`
  中学校, `"16003"` 中等教育学校, `"16004"` 高等学校, `"16005"`
  高等専門学校, `"16006"` 短期大学, `"16007"` 大学, `"16011"` 幼稚園,
  `"16012"` 特別支援学校, `"16013"` 幼保連携型認定こども園, `"16014"`
  義務教育学校, `"16015"` 各種学校, `"16016"` 専修学校.

- `school_name`, `address`: 名称 and 所在地, as published. The address
  leaves out the municipality in 2021 and includes the prefecture and
  the municipality in 2023.

- `administrator_code`: 管理者コード (P29_006): `"1"` national, `"2"`
  prefectural, `"3"` municipal, `"4"` private, `"0"` other.

- `closure_code`: 休校区分 (P29_007): `"0"` not surveyed, `"1"` open,
  `"2"` closed, as surveyed for national and public schools up to high
  schools. `"9"` is published but not in the code list.

- `campus_code`, `campus_note`: キャンパスコード (`"00"` none, `"01"`
  the main campus, and `"02"` onward the others) and 学校名備考,
  published from 2023 and `NA` before.

- `geometry`: The school as a point, in JGD2011 (EPSG:6668).

## Details

The schools are those of the School Education Act, from kindergartens to
universities, specialized training colleges (専修学校), and
miscellaneous schools (各種学校), and 幼保連携型認定こども園. A school
with several campuses has a row for each from 2023 (`campus_code`), and
a school and its campus identify a row. In 2021, 550 rows share their
`school_code` with another row, and one has none.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 学校データ, by the Ministry of Land, Infrastructure,
Transport and Tourism), and processed data must say that they were
processed.

## See also

[`school_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/school_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
school_get(2023)
}
```
