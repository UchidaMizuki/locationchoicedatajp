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

- **Grid squares** are the base zones. Their boundaries are fixed, so years compare without harmonization; they are nearly equal in size; they nest exactly; and the Population Census and the Economic Census publish statistics on them.
- The sizes are those of `grid_sizes()`: 1 km, 500 m, and 250 m, the sizes on which the Population Census, the Economic Census (1 km and 500 m), and the future population of National Land Numerical Information are published. Coarser squares (5 km and over) are coarser than many municipalities, so they cannot serve as residential zones within them, and finer squares (125 m) have no published statistics. Sparse data, such as land prices, are handled by an interpolated surface rather than by coarser squares.
- Functions on grid squares have no default size: the size is a choice of the model. Each size is built on its first call without rebuilding the others, so a size can be added to `grid_sizes()` when a source needs it.
- **Municipalities** (`city_code`, five digits with the leading zero, as published for the reference year, with the wards of designated cities) are kept because commuting origin-destination flows are published only for them. A model of residence on grid squares is matched to these flows by summing its predictions over the squares of each municipality.
- A crosswalk of grid squares to municipalities, `grid_city_get(date)`, links the two: the land area of each square in each municipality and its share (about one square in seven straddles a boundary in Tokyo). It is built from the administrative boundaries (N03 of National Land Numerical Information) in force on `date`, so a table is linked with the boundaries of its own reference date (October 1 for the Population Census, January 1 for 地価公示). N03 is released once or twice a year, on irregular dates until 2014 and on January 1 from 2015.
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
- Sites cover only some grid squares. `land_price_grid_get()` summarises them by grid square (of any size) and use, as a separate table: the number of sites, the median, and the geometric mean (prices are skewed). Squares without sites have no row. In 2020, 95% of the rows at 500 m and 79% at 1 km have a single site, so `n_points` is always given. An interpolated surface for squares without sites is planned as another separate table.
- 都道府県地価調査 (L02, as of July 1) is a separate source, `prefectural_land_price_get()`, with the same columns, from its nationwide files of 2006 onward. It shares the pipeline helpers, with its own `inst/tarchives/prefectural-land-price/columns.csv` (written by the same script) and a build function that converts forest land (020), published in yen per 10 ares, to yen per square meter. Its files until 2010 name their columns as L01. One site in 2008 has a price of 0, kept as published, so prices are checked to be non-negative.

### Crosswalk of grid squares to municipalities (`grid_city_get()`)

From 行政区域 (N03 of National Land Numerical Information, read with `ksjdata::ksj_get()`). A release is about 370 MB in 47 files by prefecture. Each release has these targets, with dynamic branches over its files:

| Target | Value | Depends on the size |
|---|---|---|
| `grid_city_<date>_files` | The files of the release, with their URLs | No |
| `grid_city_<date>_cities` | The polygons of each file dissolved by municipality (a branch per file) | No |
| `grid_city_<date>_<size>_areas` | The land area of each square in each municipality (a branch per file) | Yes |
| `grid_city_<date>_<size>` | The crosswalk of the release, read by `grid_city_get()` | Yes |

- Adding a size to `grid_sizes()` adds its targets without rebuilding any other: the dissolved polygons are shared by every size. Branches are named by their data, so a replaced file rebuilds only its own branches.
- Only the targets of the requested size are built. For 2020, the first call (500 m) took about 45 minutes with the downloads (35 without), a second size took 8 minutes (1 km), as it only cuts the polygons already dissolved, and later calls take about a second. Adding a size (tested with 80 km, since dropped) rebuilt none of the 240 targets and branches already built.
- The polygons are dissolved by municipality code (`N03_007`, the same column in every release) and cut by the squares of each size that they touch. The cutting is planar in longitude and latitude, in which the squares are rectangles, and the areas are computed in an Albers equal-area projection on the GRS80 ellipsoid. Files without a `.prj` file are set to JGD2000, the datum of the catalog for them.
- Shares are computed after binding the prefectures, as squares straddle their borders.
- Checked for 2020: the land area is 377,971 km² (377,975 km² in the official survey of areas), 1,902 municipality codes, the shares of every square sum to one, and every site of 地価公示 lies in a square of its own municipality.
- Areas are of land within the administrative boundaries. Land whose municipality is undetermined (所属未定地) is kept, with `city_code` `NA`, so that the shares of every square sum to one.

### Census grid statistics (`census_grid_get()`)

From the grid square statistics of the Population Census (地域メッシュ統計, 00200511) on e-Stat, downloaded as files by primary grid square (80 km) from its statistical GIS, without an API key. They are not in the e-Stat API.

- `inst/tarchives/census-grid/tables.csv` lists the tables (one per year, size, and table number) and `items.csv` their items, read from the definitions of the tables (`downloaddata/<stats_id>.pdf`) by `data-raw/census_grid_tables.R`. e-Stat lists the tables only in a page built by JavaScript, so their identifiers are listed by hand in the script, which checks the rest. `primary_grids.csv` lists the 176 primary squares with land, from the crosswalk of 2020.
- The years differ in what they publish: 2010 has only population by sex and households (and 250 m only for 東京都特別区部, designated cities, and prefectural capitals); 2015 and 2020 have population by age, households by size and type, and, in separate tables, labour force and commuting.
- A table is wide, one row per square and one column per item, named by its published code: a nationwide 500 m table has about half a million squares and up to 94 items, which would be tens of millions of rows in long form. Names and units are in `census_grid_items()`, as the attribute table of ksjdata.
- Each table has a target per primary square (a dynamic branch; e-Stat answers 404 for squares without residents, which give no rows) and a target that binds them. Every file is checked against the definition of its table (columns, digits of the codes, integer values).
- Suppression is kept as published: `suppression_code` (0, 1 for a square that includes suppressed squares, 2 for a suppressed square) and `merged_into_grid_code`. The list of squares merged into a square (`GASSAN`) is dropped, as it follows from `merged_into_grid_code`. Suppressed values are `NA`.
- e-Stat sometimes answers a run of requests with a page or a broken archive, so a download is retried until it is an archive of one file.
- Checked for the 500 m tables of 001-01: the population of the squares sums to the published national population in 2010 (128,057,352), 2015 (127,094,745), and 2020 (126,146,099). About a quarter of the squares are suppressed in 2015 and 2020 (109,336 of 466,145 in 2020). A table takes 4 to 8 minutes on its first call and about half a second later.

### Commuting flows (`census_commuting_get()`)

From the Population Census on the e-Stat API, read with jpstat (an API key in `ESTAT_API_KEY` is needed to build them). The table of each year and purpose is listed in `inst/tarchives/census-commuting/tables.csv`.

- 2020 uses table 0003454524 (男女，就業・通学，従業地・通学地別就業者・通学者数), whose items are employed persons (15歳以上就業者, `"work"`) and students (15歳以上通学者, `"school"`) aged 15 and over. It is the only table of 2020 that splits flows within the municipality into work at home and outside the home: the tables of commuters (通勤者数) leave out work at home.
- The place of work or school (従業地・通学地) is kept as published in `place_code`: at home (011) and outside the home (012) in the municipality of residence, another municipality (02, by destination), a municipality unknown or abroad (024), and unknown (03). Under 02, the code of the municipality of residence holds the flows of 024 again, so it is dropped. This was checked on municipalities of several sizes before relying on it, and every build checks that the flows of each municipality of residence sum to its published total.
- Municipalities are the codes without children in the table, so designated cities are split into wards, as in N03; totals of the country, prefectures, 特別区部, and designated cities are dropped. Counts written as `-` are zero, and zero flows between municipalities are kept.
- One dynamic branch per prefecture of residence. The API takes at most 100 codes in a filter and URLs of limited length, so origins are requested in groups of 100 and all destinations are requested, the totals among them being dropped afterwards.
- Checked for 2020 (work): the flows sum to the published number of employed persons aged 15 and over (57,643,225); work at home (5,766,846), unknown or abroad (450,341), and unknown (1,402,859) agree with the table of commuters (0003454528, which leaves out work at home); the 1,896 municipalities are both origins and destinations, every origin has a row for each of the 1,895 other municipalities and each sex, and all are in the crosswalk of 2020 (which also has the six villages of the Northern Territories, not surveyed). The table has 7.2 million rows; it takes about 35 minutes on its first call and 3 seconds later.
- The censuses of 2010 and 2015 publish flows to municipalities and to the wards of designated cities in separate tables, and include work at home in the flows within the municipality. They are planned, with checks that the two tables agree.
