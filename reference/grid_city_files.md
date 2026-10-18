# Files of the crosswalk of grid squares to municipalities

`grid_city_files()` lists the files of
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md):
the files by prefecture of each release of 行政区域 (N03) in
[ksjdata::ksj_available](https://rdrr.io/pkg/ksjdata/man/ksj_available.html)
since 2007, with the date of their boundaries, read from the file name.
It is used by the bundled pipeline.

## Usage

``` r
grid_city_files()
```

## Value

A tibble with one row per file: `boundary_date`, `release` (the year of
the release), `prefecture_code`, `file_name`, and `url`.

## Examples

``` r
grid_city_files()
#> # A tibble: 1,034 × 5
#>    boundary_date release prefecture_code file_name             url              
#>    <date>          <int> <chr>           <chr>                 <chr>            
#>  1 2007-04-01       2007 01              N03-070401_01_GML.zip https://nlftp.ml…
#>  2 2007-04-01       2007 02              N03-070401_02_GML.zip https://nlftp.ml…
#>  3 2007-04-01       2007 03              N03-070401_03_GML.zip https://nlftp.ml…
#>  4 2007-04-01       2007 04              N03-070401_04_GML.zip https://nlftp.ml…
#>  5 2007-04-01       2007 05              N03-070401_05_GML.zip https://nlftp.ml…
#>  6 2007-04-01       2007 06              N03-070401_06_GML.zip https://nlftp.ml…
#>  7 2007-04-01       2007 07              N03-070401_07_GML.zip https://nlftp.ml…
#>  8 2007-04-01       2007 08              N03-070401_08_GML.zip https://nlftp.ml…
#>  9 2007-04-01       2007 09              N03-070401_09_GML.zip https://nlftp.ml…
#> 10 2007-04-01       2007 10              N03-070401_10_GML.zip https://nlftp.ml…
#> # ℹ 1,024 more rows
```
