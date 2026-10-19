# Name of the target of a release of the crosswalk

`grid_city_release_target_name()` gives the name of the target of the
crosswalk of a release in grid squares of a size in the bundled
pipeline: `2020-01-01` and `"500m"` become `grid_city_20200101_500m`. It
is used by the pipeline and by
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md).

## Usage

``` r
grid_city_release_target_name(boundary_date, grid_size)
```

## Arguments

- boundary_date:

  Dates of the boundaries of releases: values of `boundary_date` in
  [`grid_city_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_files.md).

- grid_size:

  The size of the grid squares: one of
  [`grid_sizes()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_sizes.md),
  `"500m"` by default. Each size is built and cached for a release on
  its first call, without rebuilding the others.

## Value

A character vector of target names.

## Examples

``` r
grid_city_release_target_name(as.Date("2020-01-01"), "500m")
#> [1] "grid_city_20200101_500m"
```
