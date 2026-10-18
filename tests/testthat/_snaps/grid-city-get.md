# grid_city_get() errors on an invalid date

    Code
      grid_city_get("2020-13-01")
    Condition
      Error in `grid_city_get()`:
      ! `date` must be a single date, such as "2020-10-01".
    Code
      grid_city_get(2020)
    Condition
      Error in `grid_city_get()`:
      ! `date` must be a single date, such as "2020-10-01".
    Code
      grid_city_get("2000-01-01")
    Condition
      Error in `grid_city_get()`:
      ! There are no boundaries in force on "2000-01-01".
      i The first release is of "2007-04-01".

