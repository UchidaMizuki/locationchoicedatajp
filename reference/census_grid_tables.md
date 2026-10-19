# Tables of the grid square statistics of the Population Census

`census_grid_tables()` lists the tables of
[`census_grid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_get.md),
and `census_grid_items()` their items, as given in the definitions of
the tables on e-Stat. The tables of 2010 have only the population by sex
and the number of households, and its 250 m table covers only
東京都特別区部, designated cities, and prefectural capitals.

## Usage

``` r
census_grid_tables()

census_grid_items()
```

## Value

`census_grid_tables()` returns a tibble with one row per table:
`stats_id` (the identifier of the table on e-Stat), `year`,
`survey_date`, `grid_size`, `table_code`, `table_name`, and
`collection_name`, as published.

`census_grid_items()` returns a tibble with one row per item of each
table: `stats_id`, `item_code` (the name of its column in
[`census_grid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_get.md)),
`level` (the depth of the item in the table), `item_name`, and `unit`,
as published.

## Examples

``` r
census_grid_tables()
#> # A tibble: 18 × 7
#>    stats_id  year survey_date grid_size table_code table_name    collection_name
#>    <chr>    <int> <date>      <chr>     <chr>      <chr>         <chr>          
#>  1 T000608   2010 2010-10-01  1km       001-01     男女別人口総数及び世帯総… 平成２２年国勢調査－世界測地…
#>  2 T000609   2010 2010-10-01  500m      001-01     男女別人口総数及び世帯総… 平成２２年国勢調査－世界測地…
#>  3 T000649   2010 2010-10-01  250m      001-01     男女別人口総数及び世帯総… 平成２２年国勢調査－世界測地…
#>  4 T000846   2015 2015-10-01  1km       001-01     その１ 人口等基本集計に… 平成２７年国勢調査－世界測地…
#>  5 T000847   2015 2015-10-01  500m      001-01     その１ 人口等基本集計に… 平成２７年国勢調査－世界測地…
#>  6 T000876   2015 2015-10-01  250m      001-01     その１ 人口等基本集計に… 平成２７年国勢調査－世界測地…
#>  7 T000877   2015 2015-10-01  1km       001-02     その２ 人口移動集計及び… 平成２７年国勢調査－世界測地…
#>  8 T000879   2015 2015-10-01  500m      001-02     その２ 人口移動集計及び… 平成２７年国勢調査－世界測地…
#>  9 T000881   2015 2015-10-01  250m      001-02     その２ 人口移動集計及び… 平成２７年国勢調査－世界測地…
#> 10 T000878   2015 2015-10-01  1km       001-03     その３ 従業地・通学地集… 平成２７年国勢調査－世界測地…
#> 11 T000880   2015 2015-10-01  500m      001-03     その３ 従業地・通学地集… 平成２７年国勢調査－世界測地…
#> 12 T000882   2015 2015-10-01  250m      001-03     その３ 従業地・通学地集… 平成２７年国勢調査－世界測地…
#> 13 T001140   2020 2020-10-01  1km       001-01     人口及び世帯  令和２年国勢調査－世界測地系…
#> 14 T001141   2020 2020-10-01  500m      001-01     人口及び世帯  令和２年国勢調査－世界測地系…
#> 15 T001142   2020 2020-10-01  250m      001-01     人口及び世帯  令和２年国勢調査－世界測地系…
#> 16 T001143   2020 2020-10-01  1km       001-02     人口移動、就業状態等及び… 令和２年国勢調査－世界測地系…
#> 17 T001144   2020 2020-10-01  500m      001-02     人口移動、就業状態等及び… 令和２年国勢調査－世界測地系…
#> 18 T001145   2020 2020-10-01  250m      001-02     人口移動、就業状態等及び… 令和２年国勢調査－世界測地系…

# The items of the 500 m table of 2020
items <- census_grid_items()
items[items$stats_id == "T001141", ]
#> # A tibble: 50 × 5
#>    stats_id item_code  level item_name             unit 
#>    <chr>    <chr>      <int> <chr>                 <chr>
#>  1 T001141  T001141001     3 人口（総数）          人   
#>  2 T001141  T001141002     3 人口（総数） 男       人   
#>  3 T001141  T001141003     3 人口（総数） 女       人   
#>  4 T001141  T001141004     3 ０～１４歳人口 総数   人   
#>  5 T001141  T001141005     3 ０～１４歳人口 男     人   
#>  6 T001141  T001141006     3 ０～１４歳人口 女     人   
#>  7 T001141  T001141007     3 １５歳以上人口 総数   人   
#>  8 T001141  T001141008     3 １５歳以上人口 男     人   
#>  9 T001141  T001141009     3 １５歳以上人口 女     人   
#> 10 T001141  T001141010     3 １５～６４歳人口 総数 人   
#> # ℹ 40 more rows
```
