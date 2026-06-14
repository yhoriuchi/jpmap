# Transform Data

[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
moves user data into the same projected coordinate system used by
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md).

## Data Frames

``` r

library(tidyverse)
library(jpmap)

places <- tribble(
  ~place, ~lon, ~lat,
  "Tokyo", 139.767, 35.681,
  "Naha", 127.681, 26.212,
  "Ogasawara", 142.191, 27.094
)

places |>
  jpmap_transform(output_names = c("x", "y"))
#> # A tibble: 3 × 5
#>   place       lon   lat        x        y
#>   <chr>     <dbl> <dbl>    <dbl>    <dbl>
#> 1 Tokyo      140.  35.7  205212. -199414.
#> 2 Naha       128.  26.2 -683245.  657517.
#> 3 Ogasawara  142.  27.1  537219. -578089.
```

## Simple Features

If `data` is an `sf` object,
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
returns an `sf` object.

``` r

pts <- sf::st_as_sf(
  places,
  coords = c("lon", "lat"),
  crs = 4326,
  remove = FALSE
)

pts |>
  jpmap_transform()
#> Simple feature collection with 3 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -683245.1 ymin: -578088.9 xmax: 537218.7 ymax: 657516.5
#> Projected CRS: +proj=laea +lat_0=37.5 +lon_0=137.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs
#> # A tibble: 3 × 4
#>   place       lon   lat             geometry
#> * <chr>     <dbl> <dbl>          <POINT [m]>
#> 1 Tokyo      140.  35.7 (205212.3 -199413.7)
#> 2 Naha       128.  26.2 (-683245.1 657516.5)
#> 3 Ogasawara  142.  27.1 (537218.7 -578088.9)
```

Use `inset = FALSE` when you want only the projected Japan CRS and not
the Okinawa/Ogasawara inset movement.

``` r

places |>
  jpmap_transform(output_names = c("x", "y"), inset = FALSE)
#> # A tibble: 3 × 5
#>   place       lon   lat        x         y
#>   <chr>     <dbl> <dbl>    <dbl>     <dbl>
#> 1 Tokyo      140.  35.7  205212.  -199414.
#> 2 Naha       128.  26.2 -983633. -1201884.
#> 3 Ogasawara  142.  27.1  466807. -1141584.
```

You can also move only one island group.

``` r

places |>
  jpmap_transform(output_names = c("x", "y"), inset = "okinawa")
#> # A tibble: 3 × 5
#>   place       lon   lat        x         y
#>   <chr>     <dbl> <dbl>    <dbl>     <dbl>
#> 1 Tokyo      140.  35.7  205212.  -199414.
#> 2 Naha       128.  26.2 -683245.   657517.
#> 3 Ogasawara  142.  27.1  466807. -1141584.
places |>
  jpmap_transform(output_names = c("x", "y"), inset = "ogasawara")
#> # A tibble: 3 × 5
#>   place       lon   lat        x         y
#>   <chr>     <dbl> <dbl>    <dbl>     <dbl>
#> 1 Tokyo      140.  35.7  205212.  -199414.
#> 2 Naha       128.  26.2 -983633. -1201884.
#> 3 Ogasawara  142.  27.1  537219.  -578089.
```

The same switches can be written as boolean arguments when you want the
default `inset = TRUE` behavior except for one island group.

``` r

places |>
  jpmap_transform(output_names = c("x", "y"), okinawa = FALSE)
#> # A tibble: 3 × 5
#>   place       lon   lat        x         y
#>   <chr>     <dbl> <dbl>    <dbl>     <dbl>
#> 1 Tokyo      140.  35.7  205212.  -199414.
#> 2 Naha       128.  26.2 -983633. -1201884.
#> 3 Ogasawara  142.  27.1  537219.  -578089.
places |>
  jpmap_transform(output_names = c("x", "y"), ogasawara = FALSE)
#> # A tibble: 3 × 5
#>   place       lon   lat        x         y
#>   <chr>     <dbl> <dbl>    <dbl>     <dbl>
#> 1 Tokyo      140.  35.7  205212.  -199414.
#> 2 Naha       128.  26.2 -683245.   657517.
#> 3 Ogasawara  142.  27.1  466807. -1141584.
```
