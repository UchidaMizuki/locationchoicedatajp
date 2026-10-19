# Get grid square statistics of the Population Census

Returns a table of the grid square statistics (地域メッシュ統計) of the
Population Census, one row per grid square with residents, as published.
The first call for a table downloads its files from e-Stat (by primary
grid square) and builds it, which is then cached.

## Usage

``` r
census_grid_get(year, grid_size, table_code)
```

## Source

Statistics Bureau of Japan, grid square statistics of the Population
Census (国勢調査に関する地域メッシュ統計), from e-Stat:
<https://www.e-stat.go.jp/gis>. The terms of use of e-Stat, based on the
Standard Terms of Use of the Government of Japan (Version 2.0) and
compatible with CC BY 4.0, are on
<https://www.e-stat.go.jp/terms-of-use>.

## Arguments

- year:

  The year of the census: 2010, 2015, or 2020.

- grid_size:

  The size of the grid squares: one of
  [`grid_sizes()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_sizes.md).
  There is no default, as the size is a choice of the model.

- table_code:

  The number of the table (統計表), such as `"001-01"`. See
  [`census_grid_tables()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md)
  for the tables of each year and size.

## Value

A tibble with one row per grid square:

- `year`: The year of the census (integer), as of October 1.

- `release`: The year of the release the values are taken from
  (integer). It is `year`.

- `grid_code`: The code of the grid square (see
  [`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md)).

- `suppression_code`: The suppression of the square (秘匿処理), as
  published: `0` not suppressed, `1` a square that includes suppressed
  squares (合算地域), and `2` a suppressed square (秘匿地域). `NA` for
  2010, whose tables have no suppression.

- `merged_into_grid_code`: For a suppressed square, the square that
  includes its values (合算先), otherwise `NA`.

- One integer column per item, named by its code, as published (for
  example `T001141001` for 人口（総数）). Suppressed values are `NA`.
  See
  [`census_grid_items()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md)
  for the names and units of the items.

## Details

The census of each year is its own release. Grid squares have fixed
boundaries, so squares of different years compare directly. Squares
without residents have no row.

Small squares are suppressed (秘匿), except for the population by sex
and the number of households: their other values are `NA`, and they are
added to another square (`merged_into_grid_code`), whose values then
include them.

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (the grid square statistics of the
Population Census by the Statistics Bureau of Japan), and processed data
must say that they were processed.

## See also

[`census_grid_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_target.md)
to declare the table as a target.

## Examples

``` r
if (FALSE) { # interactive()
census_grid_get(2020, "500m", "001-01")
}
```
