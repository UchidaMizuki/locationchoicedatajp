# Target of prefectural land prices

`prefectural_land_price_target()` and
`prefectural_land_price_target_raw()` declare a target of a 'targets'
pipeline whose value is `prefectural_land_price_get(year)`. The target
is rerun when `year`, the URL of the file of that year, or the installed
version of locationchoicedatajp change.

## Usage

``` r
prefectural_land_price_target(name, year, ...)

prefectural_land_price_target_raw(name, year, ...)
```

## Arguments

- name:

  Name of the target: a symbol for
  [`land_price_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_target.md),
  a string for
  [`land_price_target_raw()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_target.md).

- year:

  Reference year, from 2007 to the latest release. See
  [`land_price_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_files.md)
  for the available years. To get several years, iterate over them, for
  example with
  [`purrr::map()`](https://purrr.tidyverse.org/reference/map.html): the
  coordinate reference system differs between releases, so bind them
  after making it the same.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
prefectural_land_price_target(prefectural_land_price_2020, 2020)
#> <tar_stem> 
#>   name: prefectural_land_price_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::prefectural_land_price_get(year = 2020)
#>     https://nlftp.mlit.go.jp/ksj/gml/data/L02/L02-20/L02-20_GML.zip
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
