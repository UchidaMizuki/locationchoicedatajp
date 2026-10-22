# Sources of the tables

`data_sources()` lists the source of each table of locationchoicedatajp:
one row per getter, with its publisher, terms of use, and a line of
attribution. `data_attribution()` gives the lines of attribution of the
getters used, to credit the sources in publications.

## Usage

``` r
data_sources()

data_attribution(functions = NULL)
```

## Arguments

- functions:

  Names of getters, such as `"land_price_get"`, or `NULL` (the default)
  for all of them.

## Value

`data_sources()` returns a tibble with one row per getter:
`function_name`, `source_name`, `publisher`, `source_url`,
`license_name`, `license_note`, `license_url`, and `attribution`.

`data_attribution()` returns a character vector of the distinct lines of
attribution of `functions`.

## Details

The terms of National Land Numerical Information are set for each
release, so `license_note` gives those of the releases that the getter
uses, as stated on the pages of the dataset: for example, 地価公示 is CC
BY 4.0 from 2019 and 商用可 before. Releases that cannot be used
commercially (非商用) are not used. The terms of e-Stat and of the
Statistics Bureau are compatible with CC BY 4.0.

Every source asks for credit, and data that are processed must say so.
The tables of locationchoicedatajp are processed (reshaped, renamed, and
converted), so the lines say that they were processed (加工して作成).
Complying with the terms is up to you; this package does not give legal
advice.

## Examples

``` r
data_sources()
#> # A tibble: 10 × 8
#>    function_name      source_name publisher source_url license_name license_note
#>    <chr>              <chr>       <chr>     <chr>      <chr>        <chr>       
#>  1 census_city_centr… 人口重心（国勢調査）… 総務省統計局…… https://w… 公共データ利用規約（第… CC BY 4.0互換…
#>  2 census_commuting_… 国勢調査（従業地・通… 総務省統計局…… https://w… 政府統計の総合窓口(e… 政府標準利用規約（第2…
#>  3 census_grid_get    国勢調査に関する地域… 総務省統計局…… https://w… 政府統計の総合窓口(e… 政府標準利用規約（第2…
#>  4 grid_city_get      国土数値情報（行政区… 国土交通省…… https://n… 国土数値情報 利用規約… オープンデータ（CC_…
#>  5 land_price_get     国土数値情報（地価公… 国土交通省…… https://n… 国土数値情報 利用規約… 2019年（平成31年…
#>  6 land_price_grid_g… 国土数値情報（地価公… 国土交通省…… https://n… 国土数値情報 利用規約… 2019年（平成31年…
#>  7 medical_instituti… 国土数値情報（医療機… 国土交通省…… https://n… 国土数値情報 利用規約… 2020年度（令和2年…
#>  8 prefectural_land_… 国土数値情報（都道府… 国土交通省…… https://n… 国土数値情報 利用規約… 2018年（平成30年…
#>  9 rail_station_get   国土数値情報（鉄道デ… 国土交通省…… https://n… 国土数値情報 利用規約… 2020年（令和2年）…
#> 10 school_get         国土数値情報（学校デ… 国土交通省…… https://n… 国土数値情報 利用規約… 2021年度（令和3年…
#> # ℹ 2 more variables: license_url <chr>, attribution <chr>

data_attribution(c("land_price_get", "census_grid_get"))
#> [1] "出典：政府統計の総合窓口(e-Stat)（https://www.e-stat.go.jp/）「国勢調査に関する地域メッシュ統計」（総務省統計局）を加工して作成"   
#> [2] "「国土数値情報（地価公示データ）」（国土交通省）（https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L01-2026.html）を加工して作成"
```
