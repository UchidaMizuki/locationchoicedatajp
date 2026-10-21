# Name of the target of a year of railway stations

`rail_station_target_name()` gives the name of the target of a year in
the bundled pipeline: `2020` becomes `rail_station_2020`.

## Usage

``` r
rail_station_target_name(year)
```

## Arguments

- year:

  Years: values of `year` in
  [`rail_station_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_station_files.md).

## Value

A character vector of target names.

## Examples

``` r
rail_station_target_name(2020)
#> [1] "rail_station_2020"
```
