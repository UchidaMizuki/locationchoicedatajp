# Target of land prices summarised by grid square

`land_price_grid_target()` and `land_price_grid_target_raw()` declare a
target of a 'targets' pipeline whose value is
`land_price_grid_get(year, grid_size)`. The target is rerun when the
arguments, the URL of the file of that year, or the installed version of
locationchoicedatajp change.

## Usage

``` r
land_price_grid_target(name, year, grid_size = c("500m", "1km"), ...)

land_price_grid_target_raw(name, year, grid_size = c("500m", "1km"), ...)
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

- grid_size:

  The size of the grid squares: `"500m"` (the default) or `"1km"`. Areas
  of 1 km squares are the sums of the areas of their four 500 m squares.
  Both are built and cached for a release on the first call.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
land_price_grid_target(land_price_grid_2020, 2020, "1km")
#> <tar_stem> 
#>   name: land_price_grid_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::land_price_grid_get(year = 2020, grid_size = "1km")
#>     https://nlftp.mlit.go.jp/ksj/gml/data/L01/L01-20//L01-20_GML.zip
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
