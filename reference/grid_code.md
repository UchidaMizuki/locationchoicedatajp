# Code of the grid square of points

`grid_code()` gives the code of the grid square (地域メッシュ・コード)
that contains each point, for example the sites of
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md).
It is the step that assigns every point source to grid squares, so that
they join the tables on grid squares and
[`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md).

## Usage

``` r
grid_code(x, grid_size = c("500m", "1km"))
```

## Arguments

- x:

  An `sf` object or `sfc` of points with longitude and latitude, such as
  JGD2011 or JGD2000. Their difference is far smaller than a grid
  square, so the coordinates are used as they are.

- grid_size:

  The size of the grid squares: `"500m"` (the default) or `"1km"`. Areas
  of 1 km squares are the sums of the areas of their four 500 m squares.
  Both are built and cached for a release on the first call.

## Value

A character vector of codes, nine digits for 500 m and eight digits for
1 km.

## Examples

``` r
if (FALSE) { # interactive()
sites <- land_price_get(2020)
sites$grid_code <- grid_code(sites)
}
```
