# Changelog

## locationchoicedatajp 0.0.0.9000

- Initial package infrastructure
  ([\#2](https://github.com/UchidaMizuki/locationchoicedatajp/issues/2)).
- [`census_city_centroid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_city_centroid_get.md)
  returns the population centroids of municipalities published by the
  Statistics Bureau for 2015 and 2020 as `sf` points, the representative
  points for distances, and
  [`census_city_centroid_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_city_centroid_target.md)
  declares them as a target
  ([\#8](https://github.com/UchidaMizuki/locationchoicedatajp/issues/8)).
- [`census_commuting_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_commuting_get.md)
  returns the flows of employed persons or students between
  municipalities from the Population Census of 2020, by sex and place of
  work or school (at home, outside the home, another municipality,
  unknown), with zero flows kept, and
  [`census_commuting_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_commuting_target.md)
  declares them as a target
  ([\#6](https://github.com/UchidaMizuki/locationchoicedatajp/issues/6)).
- [`census_grid_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_get.md)
  returns the grid square statistics of the Population Census (2010,
  2015, and 2020; 1 km, 500 m, and 250 m) as published, with their
  suppression,
  [`census_grid_tables()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md)
  and
  [`census_grid_items()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_tables.md)
  list their tables and items, and
  [`census_grid_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/census_grid_target.md)
  declares them as a target
  ([\#7](https://github.com/UchidaMizuki/locationchoicedatajp/issues/7)).
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
- [`prefectural_land_price_get()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/prefectural_land_price_get.md)
  returns the sites of the prefectural land price survey
  (都道府県地価調査) with their location as an `sf` tibble for every
  year from 2006, each year from its own release, with forest land
  converted to yen per square meter, and
  [`prefectural_land_price_target()`](https://uchidamizuki.github.io/locationchoicedatajp/reference/prefectural_land_price_target.md)
  declares them as a target
  ([\#9](https://github.com/UchidaMizuki/locationchoicedatajp/issues/9)).
