# Name of the target of a year of prefectural land prices

`prefectural_land_price_target_name()` gives the name of the target of a
year in the bundled pipeline: `2020` becomes
`prefectural_land_price_2020`.

## Usage

``` r
prefectural_land_price_target_name(year)
```

## Arguments

- year:

  Reference years.

## Value

A character vector of target names.

## Examples

``` r
prefectural_land_price_target_name(2020)
#> [1] "prefectural_land_price_2020"
```
