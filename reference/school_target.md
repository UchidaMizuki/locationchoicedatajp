# Target of schools

`school_target()` and `school_target_raw()` declare a target of a
'targets' pipeline whose value is `school_get(year)`. The target is
rerun when `year`, the URL of the file of that year, or the installed
version of locationchoicedatajp change.

## Usage

``` r
school_target(name, year, ...)

school_target_raw(name, year, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `school_target()`, a string for
  `school_target_raw()`.

- year:

  Reference year (school year). See
  [`school_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/school_files.md)
  for the available years. The release of 2013 is left out, as it may
  not be used commercially.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
school_target(schools_2023, 2023)
#> <tar_stem> 
#>   name: schools_2023 
#>   description:  
#>   command:
#>     locationchoicedatajp::school_get(year = 2023)
#>     https://nlftp.mlit.go.jp/ksj/gml/data/P29/P29-23/P29-23_GML.zip
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
