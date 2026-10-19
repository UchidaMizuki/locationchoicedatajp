# Sizes of grid squares

`grid_sizes()` lists the sizes of the standard grid squares
(標準地域メッシュ) that the functions of locationchoicedatajp accept:
the primary (80 km), secondary (10 km), and 5 km squares, the basic
squares (1 km), and their halves (500 m), quarters (250 m), and eighths
(125 m). Squares of each size nest exactly in those of the larger sizes.

## Usage

``` r
grid_sizes()
```

## Value

A character vector of sizes, from the default (`"500m"`) on.

## Examples

``` r
grid_sizes()
#> [1] "500m" "80km" "10km" "5km"  "1km"  "250m" "125m"
```
