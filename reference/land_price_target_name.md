# Name of the target of a year of land prices

`land_price_target_name()` gives the name of the target of a year in the
bundled pipeline: `2020` becomes `land_price_2020`. It is used by the
pipeline and by
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md).

## Usage

``` r
land_price_target_name(year)
```

## Arguments

- year:

  Reference years.

## Value

A character vector of target names.

## Examples

``` r
land_price_target_name(2020)
#> [1] "land_price_2020"
```
