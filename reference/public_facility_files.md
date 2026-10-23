# Files of the municipal offices and public meeting facilities

`public_facility_files()` lists the file of each year of
[`public_facility_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/public_facility_get.md):
the national release of 市町村役場等及び公的集会施設 (P05) in
[ksjdata::ksj_available](https://rdrr.io/pkg/ksjdata/man/ksj_available.html),
the prefix of its layers (one per prefecture), the EPSG code of its
coordinate reference system, the number of facilities, and its URL. It
is used by the bundled pipeline.

## Usage

``` r
public_facility_files()
```

## Value

A tibble with columns `year`, `file_name`, `layer_prefix`, `epsg`,
`n_facilities`, and `url`.

## Examples

``` r
public_facility_files()
#> # A tibble: 1 × 6
#>    year file_name      layer_prefix  epsg n_facilities url                      
#>   <int> <chr>          <chr>        <int>        <int> <chr>                    
#> 1  2022 P05-22_GML.zip P05-22        6668        79532 https://nlftp.mlit.go.jp…
```
