# Name of the target of a year of public facilities

`public_facility_target_name()` gives the name of the target of a year
in the bundled pipeline: `2022` becomes `public_facility_2022`.

## Usage

``` r
public_facility_target_name(year)
```

## Arguments

- year:

  Years: values of `year` in
  [`public_facility_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/public_facility_files.md).

## Value

A character vector of target names.

## Examples

``` r
public_facility_target_name(2022)
#> [1] "public_facility_2022"
```
