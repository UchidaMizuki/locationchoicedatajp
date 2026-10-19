# Target of population centroids of municipalities

`census_city_centroid_target()` and `census_city_centroid_target_raw()`
declare a target of a 'targets' pipeline whose value is
`census_city_centroid_get(year)`. The target is rerun when `year`, the
URL of the workbook, or the installed version of locationchoicedatajp
change.

## Usage

``` r
census_city_centroid_target(name, year, ...)

census_city_centroid_target_raw(name, year, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `census_city_centroid_target()`, a
  string for `census_city_centroid_target_raw()`.

- year:

  The year of the census: 2015 or 2020.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
census_city_centroid_target(centroids_2020, 2020)
#> <tar_stem> 
#>   name: centroids_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::census_city_centroid_get(year = 2020)
#>     https://www.stat.go.jp/data/kokusei/topics/zuhyou/topics135_10.xlsx
#>     0.0.0.9000 
#>   format: rds 
#>   repository: local 
#>   iteration method: vector 
#>   error mode: stop 
#>   memory mode: auto 
#>   storage mode: worker 
#>   retrieval mode: auto 
#>   deployment mode: worker 
#>   priority: 0 
#>   resources:
#>     list() 
#>   cue:
#>     seed: TRUE
#>     file: TRUE
#>     iteration: TRUE
#>     repository: TRUE
#>     format: TRUE
#>     depend: TRUE
#>     command: TRUE
#>     mode: thorough 
#>   packages:
#>     locationchoicedatajp
#>     stats
#>     graphics
#>     grDevices
#>     utils
#>     datasets
#>     methods
#>     base 
#>   library:
#>     NULL
```
