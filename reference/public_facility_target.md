# Target of municipal offices and public meeting facilities

`public_facility_target()` and `public_facility_target_raw()` declare a
target of a 'targets' pipeline whose value is
`public_facility_get(year)`. The target is rerun when `year`, the URL of
the file of that year, or the installed version of locationchoicedatajp
change.

## Usage

``` r
public_facility_target(name, year, ...)

public_facility_target_raw(name, year, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `public_facility_target()`, a string
  for `public_facility_target_raw()`.

- year:

  Reference year (fiscal year). See
  [`public_facility_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/public_facility_files.md)
  for the available years. The release of 2010 is left out, as it may
  not be used commercially.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
public_facility_target(facilities_2022, 2022)
#> <tar_stem> 
#>   name: facilities_2022 
#>   description:  
#>   command:
#>     locationchoicedatajp::public_facility_get(year = 2022)
#>     https://nlftp.mlit.go.jp/ksj/gml/data/P05/P05-22/P05-22_GML.zip
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
