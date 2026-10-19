# census_city_centroid_get() errors on a year without centroids

    Code
      census_city_centroid_get(2010)
    Condition
      Error in `census_city_centroid_get()`:
      ! `year` must be a year with population centroids.
      i Available years: 2015 and 2020.
    Code
      census_city_centroid_get()
    Condition
      Error in `census_city_centroid_get()`:
      ! `year` is absent but must be supplied.

