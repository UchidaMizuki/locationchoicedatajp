# Name of the target of a year of schools

`school_target_name()` gives the name of the target of a year in the
bundled pipeline: `2023` becomes `school_2023`.

## Usage

``` r
school_target_name(year)
```

## Arguments

- year:

  Years: values of `year` in
  [`school_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/school_files.md).

## Value

A character vector of target names.

## Examples

``` r
school_target_name(2023)
#> [1] "school_2023"
```
