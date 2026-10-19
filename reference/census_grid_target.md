# Target of grid square statistics of the Population Census

`census_grid_target()` and `census_grid_target_raw()` declare a target
of a 'targets' pipeline whose value is
`census_grid_get(year, grid_size, table_code)`. The target is rerun when
the arguments or the installed version of locationchoicedatajp change.

## Usage

``` r
census_grid_target(name, year, grid_size, table_code, ...)

census_grid_target_raw(name, year, grid_size, table_code, ...)
```

## Arguments

- name:

  Name of the target: a symbol for `census_grid_target()`, a string for
  `census_grid_target_raw()`.

- year:

  The year of the census: 2010, 2015, or 2020.

- grid_size:

  The size of the grid squares: one of
  [`grid_sizes()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_sizes.md).
  There is no default, as the size is a choice of the model.

- table_code:

  The number of the table (統計表), such as `"001-01"`. See
  [`census_grid_tables()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md)
  for the tables of each year and size.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
census_grid_target(population_2020, 2020, "500m", "001-01")
#> <tar_stem> 
#>   name: population_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::census_grid_get(year = 2020L, grid_size = "500m", 
#>         table_code = "001-01")
#>     T001141
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
