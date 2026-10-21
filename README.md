

<!-- README.md is generated from README.qmd. Please edit that file -->

# locationchoicedatajp

<!-- badges: start -->

[![R-CMD-check](https://github.com/UchidaMizuki/locationchoicedatajp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UchidaMizuki/locationchoicedatajp/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/UchidaMizuki/locationchoicedatajp/graph/badge.svg)](https://app.codecov.io/gh/UchidaMizuki/locationchoicedatajp)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

locationchoicedatajp builds analysis-ready tables for estimating
household and firm location choice models in Japan from open data only:
commuting flows, population and households, travel times, land prices,
and zone attributes, all keyed by the same zones.

- Data are not bundled. Each table is downloaded from its primary source
  and built on demand by a [targets](https://docs.ropensci.org/targets/)
  pipeline bundled with the package, and cached by
  [tarchives](https://github.com/UchidaMizuki/tarchives), so it is built
  only once.
- Each table records its source and terms of use.

Residential location is modelled on grid squares (1 km, 500 m, or 250
m), and workplaces and commuting flows on municipalities. Every table
has a reference year (`year`) and the release it is taken from
(`release`), and returns observations as published. The tables so far:

| Getter | Table | Years |
|----|----|----|
| `census_grid_get()` | Population and households by grid square (Population Census) | 2010, 2015, 2020 |
| `census_commuting_get()` | Commuting flows between municipalities by sex and place of work or school | 2020 |
| `census_city_centroid_get()` | Population centroids of municipalities | 2015, 2020 |
| `grid_city_get()` | Land area and share of each grid square in each municipality | 2007– |
| `land_price_get()`, `prefectural_land_price_get()` | Sites of 地価公示 and 都道府県地価調査 | 2007–, 2006– |
| `land_price_grid_get()` | Land prices summarised by grid square | 2007– |
| `rail_station_get()` | Railway stations (国土数値情報 N02) | 2006–2008, 2011– |
| `school_get()` | Schools (国土数値情報 P29) | 2021, 2023 |
| `medical_institution_get()` | Hospitals, clinics, and dental clinics (国土数値情報 P04) | 2020 |

Most tables are built on their first call, which downloads them;
`census_commuting_get()` needs an e-Stat API key in `ESTAT_API_KEY`. The
package is at an early stage: see the
[roadmap](https://github.com/UchidaMizuki/locationchoicedatajp/issues/1).

## Installation

You can install the development version of locationchoicedatajp from
GitHub with:

``` r
# install.packages("pak")
pak::pak("UchidaMizuki/locationchoicedatajp")
```

## Terms of use

The data come from their primary sources, each with its own terms,
compatible with CC BY 4.0 (some older releases of National Land
Numerical Information allow commercial use without being CC BY 4.0).
Published or processed data must credit the source, and processed data
must say that they were processed.

- `data_sources()` lists the source and terms of every getter, and each
  getter shows them the first time it is called in a session.
- `data_attribution()` gives the lines to credit the sources of the
  getters used, for example
  `data_attribution(c("census_commuting_get", "land_price_get"))`.
- Complying with the terms is up to you. This package does not give
  legal advice.
- The MIT license of this package applies to its code only, not to the
  data.
