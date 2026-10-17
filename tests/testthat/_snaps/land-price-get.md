# land_price_get() errors on a year without land prices

    Code
      land_price_get(2006)
    Condition
      Error in `land_price_get()`:
      ! `year` must be years with land prices.
      i Available years: 2007 to 2026.
    Code
      land_price_get("2020")
    Condition
      Error in `land_price_get()`:
      ! `year` must be years with land prices.
      i Available years: 2007 to 2026.

