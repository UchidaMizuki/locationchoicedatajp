# Get the crosswalk of grid squares to municipalities

Returns, for each grid square, the area of it in each municipality and
its share, from the administrative boundaries (行政区域, N03 of National
Land Numerical Information) in force on a date. It links tables on grid
squares to tables on municipalities, such as commuting flows. The first
call for a release downloads its files (via ksjdata, about 370 MB) and
builds the table, which takes about 45 minutes; another size of the same
release reuses the work and takes minutes. The tables are then cached,
and later calls take about a second.

## Usage

``` r
grid_city_get(date, grid_size = "500m")
```

## Source

Ministry of Land, Infrastructure, Transport and Tourism, National Land
Numerical Information, 行政区域データ (N03):
<https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2026.html>.

## Arguments

- date:

  The date of the boundaries: a `Date` or a string such as
  `"2020-10-01"`. The release in force on that date is used, which is
  the latest release with `boundary_date` on or before it. Use the
  reference date of the table to link, for example October 1 for the
  Population Census and January 1 for 地価公示. See
  [`grid_city_files()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_files.md)
  for the releases.

- grid_size:

  The size of the grid squares: one of
  [`grid_sizes()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_sizes.md),
  `"500m"` by default. Each size is built and cached for a release on
  its first call, without rebuilding the others.

## Value

A tibble with one row per grid square and municipality:

- `boundary_date`: The date of the boundaries of the release (`Date`).

- `release`: The year of the release in National Land Numerical
  Information (integer).

- `grid_code`: The code of the grid square (地域メッシュ・コード), with
  four digits for 80 km, six for 10 km, seven for 5 km, eight for 1 km,
  nine for 500 m, ten for 250 m, and eleven for 125 m.

- `city_code`: Five-digit municipality code, as published in the
  release. Designated cities are split into wards. Land whose
  municipality is undetermined (所属未定地) is `NA`.

- `area_m2`: The land area of the grid square in the municipality, in
  square meters.

- `share`: The share of the land area of the grid square in the
  municipality. The shares of a grid square sum to one.

## Details

Grid squares straddle municipal boundaries, so a square can have several
rows. Areas are of land within the administrative boundaries, so squares
on the coast or at the border of the country count only their land.
Areas are computed on the GRS80 ellipsoid (in an Albers equal-area
projection).

The first time in a session, the terms of use are shown. Published or
processed data must credit the source (National Land Numerical
Information, 行政区域データ, by the Ministry of Land, Infrastructure,
Transport and Tourism), and processed data must say that they were
processed.

## See also

[`grid_code()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_code.md)
to give points the code of their grid square.

## Examples

``` r
if (FALSE) { # interactive()
grid_city_get("2020-10-01")
}
```
