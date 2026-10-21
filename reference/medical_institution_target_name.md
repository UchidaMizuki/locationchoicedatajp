# Name of the target of a year of medical institutions

`medical_institution_target_name()` gives the name of the target of a
year in the bundled pipeline: `2020` becomes `medical_institution_2020`.

## Usage

``` r
medical_institution_target_name(year)
```

## Arguments

- year:

  Years: values of `year` in
  [`medical_institution_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/medical_institution_files.md).

## Value

A character vector of target names.

## Examples

``` r
medical_institution_target_name(2020)
#> [1] "medical_institution_2020"
```
