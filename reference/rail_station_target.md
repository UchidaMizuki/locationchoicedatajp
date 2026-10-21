# Target of railway stations

`rail_station_target()` and `rail_station_target_raw()` declare a target
of a 'targets' pipeline whose value is `rail_station_get(year)`. The
target is rerun when `year`, the URL of the file of that year, or the
installed version of locationchoicedatajp change.

## Usage

``` r
rail_station_target(name, year, ...)

rail_station_target_raw(name, year, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `rail_station_target()`, a string for
  `rail_station_target_raw()`.

- year:

  Reference year: 2006 to 2008, and 2011 to the latest release. Releases
  are as of December 31 of their year. See
  [`rail_station_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_station_files.md)
  for the available years.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
rail_station_target(stations_2020, 2020)
#> <tar_stem> 
#>   name: stations_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::rail_station_get(year = 2020)
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N02/N02-20/N02-20_GML.zip
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
