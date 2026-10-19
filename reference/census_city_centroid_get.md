# Get population centroids of municipalities

Returns the population centroid (人口重心) of each municipality
published by the Statistics Bureau for a census, as an `sf` tibble of
points. They are the representative points of municipalities, for
example for distances between them or to grid squares. The first call
for a year downloads the workbook and builds the table, which is then
cached.

## Usage

``` r
census_city_centroid_get(year)
```

## Source

Statistics Bureau of Japan, population centroids of the Population
Census (人口重心): 2015,
<https://www.stat.go.jp/data/kokusei/topics/zuhyou/topi102.xls>, and
2020,
<https://www.stat.go.jp/data/kokusei/topics/zuhyou/topics135_10.xlsx>,
from <https://www.stat.go.jp/data/kokusei/topics/topi135.html>. The
terms of use of the Statistics Bureau, the Public Data License (Version
1.0) and compatible with CC BY 4.0, are on
<https://www.stat.go.jp/info/riyou.html>.

## Arguments

- year:

  The year of the census: 2015 or 2020.

## Value

An `sf` tibble with one row per municipality:

- `year`: The year of the census (integer), as of October 1.

- `release`: The year of the release the values are taken from
  (integer). It is `year`.

- `city_code`: Five-digit municipality code, as published. Designated
  cities have a row for the whole city and one for each ward.

- `geometry`: The centroid, in JGD2000 (EPSG:4612). The workbook of 2020
  states this datum; that of 2015 does not, and is set to the same, the
  datum of the census.

## Details

The centroid of a municipality is the mean of the centres of its basic
unit blocks (基本単位区, about two million in Japan) weighted by their
population. Municipalities without residents have no centroid and no row
(in 2015, 富岡町, 大熊町, 双葉町, and 浪江町; in 2020, 双葉町). The
centroid of a municipality of islands or with a long coast can lie in
the sea or outside it (8 of 1,895 municipalities in 2020, for example
小笠原村).

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (the Statistics Bureau of Japan),
and processed data must say that they were processed.

## See also

[`census_city_centroid_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_city_centroid_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
centroids <- census_city_centroid_get(2020)

# Great-circle distances between the centroids, in meters
sf::st_distance(centroids[1:3, ])
}
```
