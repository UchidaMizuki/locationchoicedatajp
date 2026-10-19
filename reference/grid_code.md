# Code of the grid square of points

`grid_code()` gives the code of the grid square (地域メッシュ・コード)
that contains each point, for example the sites of
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md).
It is the step that assigns every point source to grid squares, so that
they join the tables on grid squares and
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md).

## Usage

``` r
grid_code(x, grid_size)
```

## Arguments

- x:

  An `sf` object or `sfc` of points with longitude and latitude, such as
  JGD2011 or JGD2000. Their difference is far smaller than a grid
  square, so the coordinates are used as they are.

- grid_size:

  The size of the grid squares: one of
  [`grid_sizes()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_sizes.md)
  (`"1km"`, `"500m"`, or `"250m"`). There is no default, as the size is
  a choice of the model. Each size is built and cached for a release on
  its first call, without rebuilding the others.

## Value

A character vector of codes (see the `grid_code` column of
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md)
for their number of digits).

## Examples

``` r
if (FALSE) { # interactive()
sites <- land_price_get(2020)
sites$grid_code <- grid_code(sites, "500m")
}
```
