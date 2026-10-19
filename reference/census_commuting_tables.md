# Tables of the commuting flows of the Population Census

`census_commuting_tables()` lists the tables of
[`census_commuting_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_commuting_get.md)
on e-Stat: one row per year and purpose, with the identifier of the
table (`stats_data_id`) and the code and name of its item (就業・通学).
It is used by the bundled pipeline.

## Usage

``` r
census_commuting_tables()
```

## Value

A tibble with columns `year`, `purpose`, `stats_data_id`, `item_code`,
and `item_name`.

## Examples

``` r
census_commuting_tables()
#> # A tibble: 2 × 5
#>    year purpose stats_data_id item_code item_name     
#>   <int> <chr>   <chr>         <chr>     <chr>         
#> 1  2020 work    0003454524    11        15歳以上就業者
#> 2  2020 school  0003454524    12        15歳以上通学者
```
