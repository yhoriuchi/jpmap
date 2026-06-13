# Transform Data

[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
moves user data into the same projected coordinate system used by
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md).

## Data Frames

``` r

library(jpmap)

places <- data.frame(
  place = c("Tokyo", "Naha", "Ogasawara"),
  lon = c(139.767, 127.681, 142.191),
  lat = c(35.681, 26.212, 27.094)
)

jpmap_transform(places, output_names = c("x", "y"))
#>       place     lon    lat         x         y
#> 1     Tokyo 139.767 35.681  205212.3 -199413.7
#> 2      Naha 127.681 26.212 -399148.9  524063.7
#> 3 Ogasawara 142.191 27.094  634278.7 -420236.5
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

jpmap_transform(pts)
#> Simple feature collection with 3 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -399148.9 ymin: -420236.5 xmax: 634278.7 ymax: 524063.7
#> Projected CRS: +proj=laea +lat_0=37.5 +lon_0=137.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs
#>       place     lon    lat                   geometry
#> 1     Tokyo 139.767 35.681 POINT (205212.3 -199413.7)
#> 2      Naha 127.681 26.212 POINT (-399148.9 524063.7)
#> 3 Ogasawara 142.191 27.094 POINT (634278.7 -420236.5)
```

Use `inset = FALSE` when you want only the projected Japan CRS and not
the Okinawa/Ogasawara inset movement.

``` r

jpmap_transform(places, output_names = c("x", "y"), inset = FALSE)
#>       place     lon    lat         x          y
#> 1     Tokyo 139.767 35.681  205212.3  -199413.7
#> 2      Naha 127.681 26.212 -983633.2 -1201884.3
#> 3 Ogasawara 142.191 27.094  466806.8 -1141584.2
```

You can also move only one island group.

``` r

jpmap_transform(places, output_names = c("x", "y"), inset = "okinawa")
#>       place     lon    lat         x          y
#> 1     Tokyo 139.767 35.681  205212.3  -199413.7
#> 2      Naha 127.681 26.212 -399148.9   524063.7
#> 3 Ogasawara 142.191 27.094  466806.8 -1141584.2
jpmap_transform(places, output_names = c("x", "y"), inset = "ogasawara")
#>       place     lon    lat         x          y
#> 1     Tokyo 139.767 35.681  205212.3  -199413.7
#> 2      Naha 127.681 26.212 -983633.2 -1201884.3
#> 3 Ogasawara 142.191 27.094  634278.7  -420236.5
```

The same switches can be written as boolean arguments when you want the
default `inset = TRUE` behavior except for one island group.

``` r

jpmap_transform(places, output_names = c("x", "y"), okinawa = FALSE)
#>       place     lon    lat         x          y
#> 1     Tokyo 139.767 35.681  205212.3  -199413.7
#> 2      Naha 127.681 26.212 -983633.2 -1201884.3
#> 3 Ogasawara 142.191 27.094  634278.7  -420236.5
jpmap_transform(places, output_names = c("x", "y"), ogasawara = FALSE)
#>       place     lon    lat         x          y
#> 1     Tokyo 139.767 35.681  205212.3  -199413.7
#> 2      Naha 127.681 26.212 -399148.9   524063.7
#> 3 Ogasawara 142.191 27.094  466806.8 -1141584.2
```
