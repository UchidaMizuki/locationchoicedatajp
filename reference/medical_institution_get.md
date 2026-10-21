# Get medical institutions

Returns the medical institutions of National Land Numerical Information
(医療機関, P04) in a year, one row per institution, as published. The
first call for a year downloads the file of that year's release (via
ksjdata) and builds the table, which is then cached.

## Usage

``` r
medical_institution_get(year)
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 医療機関データ (P04):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P04-2020.html>. See
[`data_sources()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/data_sources.md)
for the terms of use.

## Arguments

- year:

  Reference year (fiscal year). See
  [`medical_institution_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/medical_institution_files.md)
  for the available years. The releases of 2010 and 2014 are left out,
  as they may not be used commercially.

## Value

An `sf` tibble with one row per institution:

- `year`, `release`: The reference year and the year of its release,
  which is `year`.

- `institution_type_code`: 医療機関分類 (P04_001): `"1"` hospital
  (病院), `"2"` clinic (診療所), `"3"` dental clinic (歯科診療所).

- `institution_name`, `address`: 施設名称 and 所在地, as published.

- `specialties_1`, `specialties_2`, `specialties_3`: 診療科目 (P04_004
  to P04_006), as published: the specialties separated by full-width
  spaces, continued in the second and third columns when they are too
  long for the first.

- `founder_type_code`: 開設者分類 (P04_007) of hospitals: `"1"`
  national, `"2"` public, `"3"` social insurance organizations, `"4"`
  medical corporations, `"5"` individuals, `"6"` other, and `"9"` not
  classified (clinics and dental clinics).

- `beds`: 病床数 (P04_008), the number of beds, as published.

- `emergency_code`: 救急告示病院 (P04_009): `"1"` designated, `"9"` not.

- `disaster_base_code`: 災害拠点病院 (P04_010): `"1"` core, `"2"`
  regional, `"9"` not designated.

- `geometry`: The institution as a point, in JGD2011 (EPSG:6668).

## Details

The institutions are the hospitals, clinics, and dental clinics of the
Medical Care Act, including dormant ones and those inside companies, but
not those that only visit.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 医療機関データ, by the Ministry of Land, Infrastructure,
Transport and Tourism), and processed data must say that they were
processed.

## See also

[`medical_institution_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/medical_institution_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
medical_institution_get(2020)
}
```
