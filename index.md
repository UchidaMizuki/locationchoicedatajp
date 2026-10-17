# locationchoicedatajp

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

The package is at an early stage, and no tables are available yet. See
the
[roadmap](https://github.com/UchidaMizuki/locationchoicedatajp/issues/1).

## Installation

You can install the development version of locationchoicedatajp from
GitHub with:

``` r

# install.packages("pak")
pak::pak("UchidaMizuki/locationchoicedatajp")
```

## Terms of use

The data come from their primary sources, each with its own terms. Most
are published under the Public Data License (Version 1.0) of the
Government of Japan, which is compatible with CC BY 4.0. Published or
processed data must credit the source, and processed data must say that
they were processed.

- Complying with the terms is up to you. This package does not give
  legal advice.
- The MIT license of this package applies to its code only, not to the
  data.
