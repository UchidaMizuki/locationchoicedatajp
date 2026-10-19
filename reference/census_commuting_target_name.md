# Name of the target of commuting flows

`census_commuting_target_name()` gives the name of the target of a year
and purpose in the bundled pipeline: `2020` and `"work"` become
`census_commuting_2020_work`. It is used by the pipeline and by
[`census_commuting_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_commuting_get.md).

## Usage

``` r
census_commuting_target_name(year, purpose)
```

## Arguments

- year, purpose:

  Years and purposes: values of
  [`census_commuting_tables()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_commuting_tables.md).

## Value

A character vector of target names.

## Examples

``` r
census_commuting_target_name(2020, "work")
#> [1] "census_commuting_2020_work"
```
