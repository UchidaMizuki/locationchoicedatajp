# Name of the target of a year of railway lines

`rail_line_target_name()` gives the name of the target of a year in the
bundled pipeline: `2020` becomes `rail_line_2020`.

## Usage

``` r
rail_line_target_name(year)
```

## Arguments

- year:

  Years: values of `year` in
  [`rail_line_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/rail_line_files.md).

## Value

A character vector of target names.

## Examples

``` r
rail_line_target_name(2020)
#> [1] "rail_line_2020"
```
