# Files of the prefectural land prices

`prefectural_land_price_files()` lists the file of each year of
[`prefectural_land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/prefectural_land_price_get.md),
as
[`land_price_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_files.md)
does for 地価公示. It is used by the bundled pipeline.

## Usage

``` r
prefectural_land_price_files()
```

## Value

A tibble with one row per year: `year`, `file_name`, the columns
`city_code`, `use_code`, `site_number`, and `price`, `epsg`, `n_points`,
and the `url` of the file.

## Examples

``` r
prefectural_land_price_files()
#> # A tibble: 21 × 9
#>     year file_name     city_code use_code site_number price  epsg n_points url  
#>    <int> <chr>         <chr>     <chr>    <chr>       <chr> <int>    <int> <chr>
#>  1  2006 L02-06_GML.z… L01_017   L01_001  L01_002     L01_…  4612    25346 http…
#>  2  2007 L02-07_GML.z… L01_017   L01_001  L01_002     L01_…  4612    24374 http…
#>  3  2008 L02-08_GML.z… L01_017   L01_001  L01_002     L01_…  4612    23749 http…
#>  4  2009 L02-09_GML.z… L01_017   L01_001  L01_002     L01_…  4612    23024 http…
#>  5  2010 L02-10_GML.z… L01_017   L01_001  L01_002     L01_…  4612    22701 http…
#>  6  2011 L02-11_GML.z… L02_017   L02_001  L02_002     L02_…  4612    22460 http…
#>  7  2012 L02-12_GML.z… L02_017   L02_001  L02_002     L02_…  4612    22233 http…
#>  8  2013 L02-13_GML.z… L02_017   L02_001  L02_002     L02_…  4612    21958 http…
#>  9  2014 L02-14.zip    L02_017   L02_001  L02_002     L02_…  4612    21709 http…
#> 10  2015 L02-15_GML.z… L02_017   L02_001  L02_002     L02_…  4612    21700 http…
#> # ℹ 11 more rows
```
