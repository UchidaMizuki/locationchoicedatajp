# Architecture

## Purpose

locationchoicedatajp builds analysis-ready tables for estimating household and firm location choice models in Japan from open data: commuting flows, population and households, travel times, land prices, and zone attributes. It is the data layer; estimation belongs in a separate package. See the roadmap in issue #1.

- Each table has a getter, `<table>_get()`, and target factories, `<table>_target()` and `<table>_target_raw()`, which declare a target of a 'targets' pipeline whose value is the getter's.
- Data are not bundled. Each table is built on demand by a pipeline bundled with the package and cached by tarchives.

Out of scope: estimation, non-public microdata, and redistributing data.

## Principles

- **Simple, readable code.** One small function per step. Plain tibbles; no tibble subclasses, no hidden columns or attributes.
- **Reuse the data packages built on tarchives.** National Land Numerical Information is read through ksjdata, never downloaded again.
- **Values as published.** Codes keep their leading zeros, published zeros stay distinct from blank cells (`NA`), and classifications are not harmonized silently.
- **Observations, not summaries.** A getter returns the unit the source publishes (a site of 地価公示, a grid square of the census), with its location. Summaries over zones, such as the median price by grid square, are separate tables that name their statistic and their zone, and are never mixed with the observations. Values estimated for unobserved zones (interpolation) are separate tables too.
- **Tidy tables.** One row per observation and one column per variable, as plain tibbles, or `sf` tibbles when the observation has a location.
- **Checked before trusted.** Every pipeline checks what it reads (keys, ranges, counts), and fails rather than returning doubtful values.

## Time

A value has up to three dates, and a table never mixes them silently:

| Concept | Column | Meaning |
|---|---|---|
| Reference year | `year` | The year the value describes. Its exact date depends on the source (地価公示 is as of January 1, the Population Census as of October 1) and is documented by each getter. |
| Release | `release` | The year of the publication the value is taken from. |
| Boundary date | `boundary_date` | The date of the administrative boundaries a table of zones describes (`grid_city_get()`). Municipality codes are kept as published for the reference date of each table, which picks the boundaries in force on it (see [Zones](#zones)). |

Sources publish the same reference year more than once:

- A release can carry values of past years. The 2026 release of 地価公示 has the price of every current site in every year since 1983, and the 2020 Population Census republishes the population of 2015 on the zones of 2020.
- A release can be replaced by a revised one (速報 then 確報, or a corrected file).

So the latest release is not taken as the truth for every year. Instead:

1. **Each year comes from its own release by default** (`release == year`). This is what was known at the time, covers every site or zone that existed then (the history in a later release covers only the sites that survived to it), and does not change when a new release is published. Adding a release adds a year, and never changes the values of the years already built.
2. **Every table has a `release` column**, even where it equals `year`, so the schema stays the same when a table gains values from a later release.
3. **Values from a later release are opt-in.** A getter may gain a `release` argument to take every year from one release (for example, a panel of sites or zones that is consistent across years). It is added when a model needs it, and never mixed with the default in one result.
4. **A revised file rebuilds its target.** The URL of each file is part of the command of its target, so a replaced file is downloaded again, and no other target is rebuilt. Revisions are taken in by updating the package; a past revision is not kept.

Definitions also change between releases, and are kept as published: 地価公示 has seven use categories until 2012 and five from 2013, and its files of 2014 to 2016 have only three. Each getter documents the breaks it knows of.

## Zones

Residential location is modelled on grid squares (地域メッシュ), and workplaces and commuting flows on municipalities:

- **Grid squares** are the base zones. Their boundaries are fixed, so years compare without harmonization; they are nearly equal in size; they nest exactly (1 km, 500 m, 250 m); and the Population Census and the Economic Census publish statistics on them. The default size is 500 m, which is fine enough within cities without leaving most squares empty or suppressed (250 m).
- **Municipalities** (`city_code`, five digits with the leading zero, as published for the reference year, with the wards of designated cities) are kept because commuting origin-destination flows are published only for them. A model of residence on grid squares is matched to these flows by summing its predictions over the squares of each municipality.
- A crosswalk of grid squares to municipalities, `grid_city_get(date)`, links the two: the land area of each 500 m square in each municipality and its share (about one square in seven straddles a boundary in Tokyo). It is built from the administrative boundaries (N03 of National Land Numerical Information) in force on `date`, so a table is linked with the boundaries of its own reference date (October 1 for the Population Census, January 1 for 地価公示). N03 is released once or twice a year, on irregular dates until 2014 and on January 1 from 2015.
- Tables with a location (`sf` points) are not given a grid square code: `grid_code()` assigns points to squares, the same way for every point source.
- Harmonizing municipality codes to the zones of one reference year (municipal mergers) is a separate, shared step, added once jpcity supports it. It will take the code and its reference date, so every table must keep `year` and the published code.

Known limits of grid squares, and how they are handled:

- Census grid statistics are compiled by assigning basic unit blocks (基本単位区) to squares, and the census publishes fewer cross-tabulations for squares than for small areas (町丁・字). Small areas may be added as a secondary zone system, linked through the grid squares, if a model needs those tables.
- Small squares have small counts, which are suppressed or zero; models of shares handle zeros (for example by PPML), and summaries by size let results be checked against the size of the squares.
- Squares straddle municipal boundaries, which only matters where they are matched to municipal flows (through the crosswalk).

## Layout

- `R/`: getters, target factories, and the functions that the pipelines need from the package (exported with `@keywords internal`, since the pipelines use only exported functions).
- `inst/tarchives/<table>/_targets.R`: one pipeline per table, for example `land-price`, with one target per reference year. Every `_targets.R` has the same few lines.
- `inst/tarchives/<table>/*.csv`: the facts a pipeline needs about each release (for example, the columns of each release of 地価公示), kept as text so that changes are reviewed as diffs.
- `inst/tarchives/R/`: helpers shared by the pipelines.
- `data-raw/`: scripts run by the maintainer, never by users or tests, that write the CSV files of `inst/tarchives/` (they need the network).
- `tests/testthat/`: unit tests on small synthetic data. They do not use the network.

## Columns

- Columns are in snake_case. `_code` is a code from an official classification, `_name` is a label, and counts are named `n_<things>`.
- Money and other quantities carry their unit in the name (`price_jpy_per_m2`), and summaries also their statistic (`price_median_jpy_per_m2`).
- Every table starts with `year` and `release`, then its keys, then its values.

## Terms of use

Each getter shows the terms of use of its sources the first time it is called in a session, as ksjdata does, and documents them under `@source`. A registry of sources with their attribution text (issue #4) is added with the second source family (the Population Census), when there is more than one kind of terms to collect.

## Tables

### Land prices (`land_price_get()`)

From 地価公示 (L01 of National Land Numerical Information, read with `ksjdata::ksj_get()`). Prices are as of January 1 of `year`, in yen per square meter.

- One row per site, as an `sf` tibble of points: `year`, `release`, `city_code`, `use_code`, `site_number` (which together identify a site within a year), `price_jpy_per_m2`, and `geometry`.
- One target per year, from the nationwide file of that year's release (2007 onward). Earlier releases are split by prefecture, and are left for later. A call returns one year, as the coordinate reference system differs between releases (JGD2000 until 2023, JGD2011 from 2024) and is not transformed. The files until 2017 have no `.prj` file, and are set to JGD2000, the datum of the catalog for them.
- The layout of the files changes between releases, and the attribute table describes only the latest, so the columns of each release are listed in `inst/tarchives/land-price/columns.csv`. `data-raw/land_price_columns.R` finds them from their contents, and the pipeline checks them again: every municipality code has five digits with a valid prefecture, every use code and site number has three digits, every price is a positive number, the coordinate reference system is the one recorded, and the number of sites is the one recorded.
- Sites cover only some grid squares. `land_price_grid_get()` summarises them by grid square (500 m or 1 km) and use, as a separate table: the number of sites, the median, and the geometric mean (prices are skewed). Squares without sites have no row. In 2020, 95% of the rows at 500 m and 79% at 1 km have a single site, so `n_points` is always given. An interpolated surface for squares without sites is planned as another separate table.
- 都道府県地価調査 (L02, as of July 1) is planned as a second, separate source.

### Crosswalk of grid squares to municipalities (`grid_city_get()`)

From 行政区域 (N03 of National Land Numerical Information, read with `ksjdata::ksj_get()`), one target per release and prefecture (a release is about 370 MB in 47 files), and two per release that bind its prefectures into 500 m and 1 km squares, so that a call reads one target. The first call for a release takes about 45 minutes, including the downloads; later calls take about a second.

- The polygons are dissolved by municipality code (`N03_007`, the same column in every release) and cut by the 500 m squares they touch. The cutting is planar in longitude and latitude, in which the squares are rectangles, and the areas are computed in an Albers equal-area projection on the GRS80 ellipsoid. Files without a `.prj` file are set to JGD2000, the datum of the catalog for them.
- Shares are computed after binding the prefectures, as squares straddle their borders. 1 km squares sum the areas of their four 500 m squares, whose codes start with the code of the 1 km square.
- Checked for 2020: the land area is 377,971 km² (377,975 km² in the official survey of areas), 1,902 municipality codes, the shares of every square sum to one, and every site of 地価公示 lies in a square of its own municipality.
- Areas are of land within the administrative boundaries. Land whose municipality is undetermined (所属未定地) is kept, with `city_code` `NA`, so that the shares of every square sum to one.
