# Contributing to locationchoicedatajp

## Issues

- Report a bug with a minimal reproducible example, ideally made with [reprex](https://reprex.tidyverse.org/).
- Propose a new data source with the "New data source" template. Check its terms of use first: the package only uses open data that can be downloaded from the primary source.

## Pull requests

- Open an issue first for anything beyond a small fix, so the design can be agreed before the code is written.
- Follow the [tidyverse style guide](https://style.tidyverse.org/) and format the code with [air](https://posit-dev.github.io/air/) (`air format .`).
- Add tests for new code with testthat. Unit tests must not use the network.
- Add a bullet to `NEWS.md` for every user-facing change.
- Run `devtools::check()` before opening the pull request.
