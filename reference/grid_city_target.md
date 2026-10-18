# Target of the crosswalk of grid squares to municipalities

`grid_city_target()` and `grid_city_target_raw()` declare a target of a
'targets' pipeline whose value is `grid_city_get(date, grid_size)`. The
target is rerun when the arguments, the URLs of the files of the
release, or the installed version of locationchoicedatajp change.

## Usage

``` r
grid_city_target(name, date, grid_size = c("500m", "1km"), ...)

grid_city_target_raw(name, date, grid_size = c("500m", "1km"), ...)
```

## Arguments

- name:

  Name of the target: a symbol for `grid_city_target()`, a string for
  `grid_city_target_raw()`.

- date:

  The date of the boundaries: a `Date` or a string such as
  `"2020-10-01"`. The release in force on that date is used, which is
  the latest release with `boundary_date` on or before it. Use the
  reference date of the table to link, for example October 1 for the
  Population Census and January 1 for 地価公示. See
  [`grid_city_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_files.md)
  for the releases.

- grid_size:

  The size of the grid squares: `"500m"` (the default) or `"1km"`. Areas
  of 1 km squares are the sums of the areas of their four 500 m squares.
  Both are built and cached for a release on the first call.

- ...:

  Other arguments passed to
  [`targets::tar_target_raw()`](https://docs.ropensci.org/targets/reference/tar_target.html).

## Value

A target object.

## Examples

``` r
grid_city_target(grid_city_2020, "2020-10-01")
#> <tar_stem> 
#>   name: grid_city_2020 
#>   description:  
#>   command:
#>     locationchoicedatajp::grid_city_get(date = "2020-10-01", grid_size = "500m")
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_01_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_02_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_03_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_04_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_05_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_06_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_07_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_08_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_09_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_10_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_11_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_12_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_13_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_14_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_15_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_16_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_17_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_18_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_19_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_20_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_21_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_22_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_23_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_24_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_25_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_26_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_27_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_28_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_29_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_30_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_31_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_32_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_33_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_34_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_35_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_36_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_37_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_38_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_39_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_40_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_41_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_42_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_43_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_44_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_45_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_46_GML.zip
#>     https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2020/N03-20200101_47_GML.zip
#>     0.0.0.9000 
#>   format: rds 
#>   repository: local 
#>   iteration method: vector 
#>   error mode: stop 
#>   memory mode: auto 
#>   storage mode: worker 
#>   retrieval mode: auto 
#>   deployment mode: worker 
#>   priority: 0 
#>   resources:
#>     list() 
#>   cue:
#>     seed: TRUE
#>     file: TRUE
#>     iteration: TRUE
#>     repository: TRUE
#>     format: TRUE
#>     depend: TRUE
#>     command: TRUE
#>     mode: thorough 
#>   packages:
#>     locationchoicedatajp
#>     stats
#>     graphics
#>     grDevices
#>     utils
#>     datasets
#>     methods
#>     base 
#>   library:
#>     NULL
```
