# Changelog

## locationchoicedatajp 0.0.0.9000

- Initial package infrastructure
  ([\#2](https://github.com/UchidaMizuki/locationchoicedatajp/issues/2)).
- [`grid_city_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_get.md)
  returns the land area and share of each grid square in each
  municipality, from the administrative boundaries in force on a date,
  and
  [`grid_city_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_city_target.md)
  declares it as a target
  ([\#5](https://github.com/UchidaMizuki/locationchoicedatajp/issues/5)).
- [`grid_code()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_code.md)
  gives points, such as the sites of
  [`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md),
  the code of their grid square
  ([\#5](https://github.com/UchidaMizuki/locationchoicedatajp/issues/5)).
- [`grid_sizes()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/grid_sizes.md)
  lists the sizes of grid squares (1 km, 500 m, and 250 m), which every
  function on grid squares takes without a default. Each size is built
  on its first call without rebuilding the others
  ([\#5](https://github.com/UchidaMizuki/locationchoicedatajp/issues/5)).
- [`land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_get.md)
  returns the sites of the official land prices (地価公示) with their
  location as an `sf` tibble for every year from 2007, each year from
  its own release, and
  [`land_price_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_target.md)
  declares them as a target
  ([\#9](https://github.com/UchidaMizuki/locationchoicedatajp/issues/9)).
- [`land_price_grid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_grid_get.md)
  summarises the sites of the land prices by grid square and use (number
  of sites, median, and geometric mean), and
  [`land_price_grid_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/land_price_grid_target.md)
  declares it as a target
  ([\#9](https://github.com/UchidaMizuki/locationchoicedatajp/issues/9)).
