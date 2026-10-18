# Get land prices summarised by grid square

Summarises the sites of
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md)
in a year by grid square and use: the number of sites, and the median
and the geometric mean of their prices. It is a summary, not an
observation: use
[`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md)
for the sites.

## Usage

``` r
land_price_grid_get(year, grid_size = c("500m", "1km"))
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 地価公示データ (L01):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L01-2026.html>. The
terms of use are on
<https://nlftp.mlit.go.jp/ksj/other/agreement_01.html>.

## Arguments

- year:

  Reference year, from 2007 to the latest release. See
  [`land_price_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_files.md)
  for the available years. To get several years, iterate over them, for
  example with
  [`purrr::map()`](https://purrr.tidyverse.org/reference/map.html): the
  coordinate reference system differs between releases, so bind them
  after making it the same.

- grid_size:

  The size of the grid squares: `"500m"` (the default) or `"1km"`. Areas
  of 1 km squares are the sums of the areas of their four 500 m squares.
  Both are built and cached for a release on the first call.

## Value

A tibble with one row per grid square and use with at least one site:

- `year`, `release`: As in
  [`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md).

- `grid_code`: The code of the grid square (see
  [`grid_code()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_code.md)).

- `use_code`: The use of the sites, as in
  [`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md).
  Uses are not mixed.

- `n_points`: The number of sites.

- `price_median_jpy_per_m2`: The median price of the sites, in yen per
  square meter.

- `price_geometric_mean_jpy_per_m2`: The geometric mean price of the
  sites, in yen per square meter.

## Details

Sites cover only some grid squares, so most squares have no row, and
most squares with a row have a single site, especially at 500 m. Squares
are not filled in. Prices are skewed, so the geometric mean (the
exponential of the mean of log prices) is given rather than the
arithmetic mean.

## See also

[`land_price_grid_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_grid_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
land_price_grid_get(2020, "1km")
}
```
