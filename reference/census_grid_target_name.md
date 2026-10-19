# Name of the target of a census grid table

`census_grid_target_name()` gives the name of the target of a table of
[`census_grid_tables()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md)
in the bundled pipeline: `T001141` becomes `census_grid_t001141`. It is
used by the pipeline and by
[`census_grid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_get.md).

## Usage

``` r
census_grid_target_name(stats_id)
```

## Arguments

- stats_id:

  Identifiers of tables: values of `stats_id` in
  [`census_grid_tables()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md).

## Value

A character vector of target names.

## Examples

``` r
census_grid_target_name("T001141")
#> [1] "census_grid_t001141"
```
