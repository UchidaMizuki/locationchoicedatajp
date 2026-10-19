# census_grid_get() errors on a table that does not exist

    Code
      census_grid_get(2010, "500m", "001-02")
    Condition
      Error in `census_grid_get()`:
      ! There is no table "001-02" of 2010 at 500m.
      i See `census_grid_tables()` for the tables.
    Code
      census_grid_get(2020, "500m")
    Condition
      Error in `census_grid_get()`:
      ! `table_code` is absent but must be supplied.

