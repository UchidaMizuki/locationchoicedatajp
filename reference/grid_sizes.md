# Sizes of grid squares

`grid_sizes()` lists the sizes of the standard grid squares
(標準地域メッシュ) that the functions of locationchoicedatajp take: the
basic squares (1 km) and their halves (500 m) and quarters (250 m). They
are the sizes on which the Population Census, the Economic Census (1 km
and 500 m), and the future population of National Land Numerical
Information are published, and they nest exactly. Coarser squares (5 km
and over) are coarser than many municipalities, and finer squares (125
m) have no published statistics.

## Usage

``` r
grid_sizes()
```

## Value

A character vector of sizes, from the coarsest.

## Details

The functions have no default size, as the size is a choice of the
model.

## Examples

``` r
grid_sizes()
#> [1] "1km"  "500m" "250m"
```
