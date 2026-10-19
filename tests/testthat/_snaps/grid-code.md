# grid_code() errors on geometries other than points

    Code
      grid_code(polygon, "500m")
    Condition
      Error in `grid_code()`:
      ! `x` must have points.
    Code
      grid_code(projected, "500m")
    Condition
      Error in `grid_code()`:
      ! `x` must have longitude and latitude.

# grid_code() needs a size of grid_sizes()

    Code
      grid_code(points)
    Condition
      Error in `grid_code()`:
      ! `grid_size` is absent but must be supplied.
    Code
      grid_code(points, "10km")
    Condition
      Error in `grid_code()`:
      ! `grid_size` must be one of "1km", "500m", or "250m", not "10km".
      i Did you mean "1km"?

