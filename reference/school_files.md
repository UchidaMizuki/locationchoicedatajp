# Files of the schools

`school_files()` lists the file of each year of
[`school_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/school_get.md):
the national release of 学校 (P29) in
[ksjdata::ksj_available](https://rdrr.io/pkg/ksjdata/man/ksj_available.html),
its layer, the EPSG code of its coordinate reference system, the number
of schools, and its URL. It is used by the bundled pipeline.

## Usage

``` r
school_files()
```

## Value

A tibble with columns `year`, `file_name`, `layer`, `epsg`, `n_schools`,
and `url`.

## Examples

``` r
school_files()
#> # A tibble: 2 × 6
#>    year file_name      layer   epsg n_schools url                               
#>   <int> <chr>          <chr>  <int>     <int> <chr>                             
#> 1  2021 P29-21_GML.zip P29-21  6668     57230 https://nlftp.mlit.go.jp/ksj/gml/…
#> 2  2023 P29-23_GML.zip P29-23  6668     56807 https://nlftp.mlit.go.jp/ksj/gml/…
```
