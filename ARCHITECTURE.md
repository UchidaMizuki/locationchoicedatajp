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
- **Checked before trusted.** Every pipeline checks what it reads (keys, ranges, counts), and fails rather than returning doubtful values.

## Time

A value has up to three dates, and a table never mixes them silently:

| Concept | Column | Meaning |
|---|---|---|
| Reference year | `year` | The year the value describes. Its exact date depends on the source (地価公示 is as of January 1, the Population Census as of October 1) and is documented by each getter. |
| Release | `release` | The year of the publication the value is taken from. |
| Zone year | (none yet) | The year of the zones the value is keyed by. Zones are kept as published, so it is the reference year for now (see [Zones](#zones)). |

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

Tables are keyed by zones as published: municipality codes (`city_code`, five digits with the leading zero) as of the reference year, with the wards of designated cities as published.

- Harmonizing codes to the zones of one reference year (municipal mergers) is a separate, shared step, added once jpcity supports it. It will take the code and its reference date, so every table must keep `year` and the published code.
- Grid squares (500 m or 1 km) are planned as a second zone system (issue #5).

## Layout

- `R/`: getters, target factories, and the functions that the pipelines need from the package (exported with `@keywords internal`, since the pipelines use only exported functions).
- `inst/tarchives/<table>/_targets.R`: one pipeline per table, for example `land-price`, with one target per reference year. Every `_targets.R` has the same few lines.
- `inst/tarchives/<table>/*.csv`: the facts a pipeline needs about each release (for example, the columns of each release of 地価公示), kept as text so that changes are reviewed as diffs.
- `inst/tarchives/R/`: helpers shared by the pipelines.
- `data-raw/`: scripts run by the maintainer, never by users or tests, that write the CSV files of `inst/tarchives/` (they need the network).
- `tests/testthat/`: unit tests on small synthetic data. They do not use the network.

## Columns

- Columns are in snake_case. `_code` is a code from an official classification, `_name` is a label, and counts are named `n_<things>`.
- Money and other quantities carry their unit in the name (`price_median_jpy_per_m2`).
- Every table starts with `year` and `release`, then its keys, then its values.

## Terms of use

Each getter shows the terms of use of its sources the first time it is called in a session, as ksjdata does, and documents them under `@source`. A registry of sources with their attribution text (issue #4) is added with the second source family (the Population Census), when there is more than one kind of terms to collect.

## Tables

### Land prices (`land_price_get()`)

From 地価公示 (L01 of National Land Numerical Information, read with `ksjdata::ksj_get()`). Prices are as of January 1 of `year`, in yen per square meter.

- One target per year, from the nationwide file of that year's release (2007 onward). Earlier releases are split by prefecture, and are left for later.
- The layout of the files changes between releases, and the attribute table describes only the latest, so the columns of each release are listed in `inst/tarchives/land-price/columns.csv`. `data-raw/land_price_columns.R` finds them from their contents, and the pipeline checks them again: every municipality code has five digits with a valid prefecture, every use code has three digits, every price is a positive number, and the number of sites is the one recorded.
- The table summarises the sites by municipality and use: the number of sites and the median and mean price. Sites are not weighted.
- 都道府県地価調査 (L02, as of July 1) is planned as a second source of the same table.
