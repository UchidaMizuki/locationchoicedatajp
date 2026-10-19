# Name of the target of population centroids

`census_city_centroid_target_name()` gives the name of the target of a
year in the bundled pipeline: `2020` becomes
`census_city_centroid_2020`.

## Usage

``` r
census_city_centroid_target_name(year)
```

## Arguments

- year:

  Years: values of `year` in
  [`census_city_centroid_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_city_centroid_files.md).

## Value

A character vector of target names.

## Examples

``` r
census_city_centroid_target_name(2020)
#> [1] "census_city_centroid_2020"
```
