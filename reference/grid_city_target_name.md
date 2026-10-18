# Name of the target of a file of the crosswalk

`grid_city_target_name()` gives the name of the target of a file of
[`grid_city_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_files.md)
in the bundled pipeline: `N03-20200101_13_GML.zip` becomes
`grid_city_20200101_13`. `grid_city_release_target_name()` gives the
name of the target that binds the files of a release into grid squares
of a size: `2020-01-01` and `"500m"` become `grid_city_20200101_500m`.
They are used by the pipeline and by
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md).

## Usage

``` r
grid_city_target_name(file_name)

grid_city_release_target_name(boundary_date, grid_size)
```

## Arguments

- file_name:

  Names of files: values of `file_name` in
  [`grid_city_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_files.md).

- boundary_date:

  Dates of the boundaries of releases: values of `boundary_date` in
  [`grid_city_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_files.md).

- grid_size:

  The size of the grid squares: `"500m"` (the default) or `"1km"`. Areas
  of 1 km squares are the sums of the areas of their four 500 m squares.
  Both are built and cached for a release on the first call.

## Value

A character vector of target names.

## Examples

``` r
grid_city_target_name("N03-20200101_13_GML.zip")
#> [1] "grid_city_20200101_13"
grid_city_release_target_name(as.Date("2020-01-01"), "500m")
#> [1] "grid_city_20200101_500m"
```
