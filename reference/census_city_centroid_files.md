# Files of the population centroids

`census_city_centroid_files()` lists the workbook of each year of
[`census_city_centroid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_city_centroid_get.md):
its URL and how its angles are written (`"decimal"` degrees or `"dms"`
as DDDMMSS.ss). It is used by the bundled pipeline.

## Usage

``` r
census_city_centroid_files()
```

## Value

A tibble with columns `year`, `url`, and `angle`.

## Examples

``` r
census_city_centroid_files()
#> # A tibble: 2 × 3
#>    year url                                                                angle
#>   <int> <chr>                                                              <chr>
#> 1  2015 https://www.stat.go.jp/data/kokusei/topics/zuhyou/topi102.xls      dms  
#> 2  2020 https://www.stat.go.jp/data/kokusei/topics/zuhyou/topics135_10.xl… deci…
```
