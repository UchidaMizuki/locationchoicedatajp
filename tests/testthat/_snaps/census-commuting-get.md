# census_commuting_get() errors on unavailable flows

    Code
      census_commuting_get(2015, "work")
    Condition
      Error in `census_commuting_get()`:
      ! There are no commuting flows of 2015.
      i Available years: 2020.
    Code
      census_commuting_get(2020, "shopping")
    Condition
      Error in `census_commuting_get()`:
      ! `purpose` must be one of "work" or "school", not "shopping".
    Code
      census_commuting_get(2020)
    Condition
      Error in `census_commuting_get()`:
      ! `purpose` is absent but must be supplied.

