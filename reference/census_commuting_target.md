# Target of commuting flows of the Population Census

`census_commuting_target()` and `census_commuting_target_raw()` declare
a target of a 'targets' pipeline whose value is
`census_commuting_get(year, purpose)`. The target is rerun when the
arguments, the table on e-Stat, or the installed version of
locationchoicedatajp change.

## Usage

``` r
census_commuting_target(name, year, purpose, ...)

census_commuting_target_raw(name, year, purpose, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `census_commuting_target()`, a string
  for `census_commuting_target_raw()`.

- year:

  The year of the census: 2020. Earlier censuses publish their flows in
  other layouts, and are planned.

- purpose:

  The purpose of the trip: `"work"` for employed persons aged 15 and
  over (15歳以上就業者) or `"school"` for students aged 15 and over
  (15歳以上通学者). There is no default, as the purpose is a choice of
  the model.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
census_commuting_target(commuting_2020, 2020, "work")
#> <tar_stem> 
#>   name: commuting_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::census_commuting_get(year = 2020L, purpose = "work")
#>     0003454524
#>     11
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
