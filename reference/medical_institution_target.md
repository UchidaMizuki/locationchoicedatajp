# Target of medical institutions

`medical_institution_target()` and `medical_institution_target_raw()`
declare a target of a 'targets' pipeline whose value is
`medical_institution_get(year)`. The target is rerun when `year`, the
URL of the file of that year, or the installed version of
locationchoicedatajp change.

## Usage

``` r
medical_institution_target(name, year, ...)

medical_institution_target_raw(name, year, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `medical_institution_target()`, a
  string for `medical_institution_target_raw()`.

- year:

  Reference year (fiscal year). See
  [`medical_institution_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/medical_institution_files.md)
  for the available years. The releases of 2010 and 2014 are left out,
  as they may not be used commercially.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
medical_institution_target(institutions_2020, 2020)
#> <tar_stem> 
#>   name: institutions_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::medical_institution_get(year = 2020)
#>     https://nlftp.mlit.go.jp/ksj/gml/data/P04/P04-20/P04-20_GML.zip
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
