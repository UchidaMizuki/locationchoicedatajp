# Files of the medical institutions

`medical_institution_files()` lists the file of each year of
[`medical_institution_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/medical_institution_get.md):
the national release of 医療機関 (P04) in
[ksjdata::ksj_available](https://rdrr.io/pkg/ksjdata/man/ksj_available.html),
its layer, the EPSG code of its coordinate reference system, the number
of institutions, and its URL. It is used by the bundled pipeline.

## Usage

``` r
medical_institution_files()
```

## Value

A tibble with columns `year`, `file_name`, `layer`, `epsg`,
`n_institutions`, and `url`.

## Examples

``` r
medical_institution_files()
#> # A tibble: 1 × 6
#>    year file_name      layer   epsg n_institutions url                          
#>   <int> <chr>          <chr>  <int>          <int> <chr>                        
#> 1  2020 P04-20_GML.zip P04-20  6668         181312 https://nlftp.mlit.go.jp/ksj…
```
