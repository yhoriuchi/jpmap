# Transform Data to the jpmap Projection

Transforms geographic data to the jpmap projected coordinate system.
When `inset = TRUE`, Okinawa and Ogasawara are moved to visible inset
locations. Use `okinawa = FALSE`, `ogasawara = FALSE`,
`inset = "okinawa"`, or `inset = "ogasawara"` to transport only one
island group.

## Usage

``` r
jpmap_transform(
  data,
  input_names = c("lon", "lat"),
  output_names = input_names,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE
)
```

## Arguments

- data:

  An `sf` object, `sfc` geometry vector, or data frame.

- input_names:

  Longitude and latitude column names for data frames.

- output_names:

  Output coordinate column names for data frames.

- inset:

  Inset behavior. Use `TRUE` to move both Okinawa and Ogasawara, `FALSE`
  for no movement, or a character vector containing `"okinawa"` and/or
  `"ogasawara"` to move selected island groups.

- okinawa:

  Whether Okinawa should be moved when `inset` includes it.

- ogasawara:

  Whether Ogasawara should be moved when `inset` includes it.

## Value

An object of the same general type as `data`.

## Examples

``` r
places <- data.frame(
  lon = c(139.767, 127.681, 142.191),
  lat = c(35.681, 26.212, 27.094)
)
jpmap_transform(places, output_names = c("x", "y"))
#>       lon    lat         x         y
#> 1 139.767 35.681  205212.3 -199413.7
#> 2 127.681 26.212 -394918.6  529024.8
#> 3 142.191 27.094  637228.4 -417843.4
jpmap_transform(places, output_names = c("x", "y"), inset = "okinawa")
#>       lon    lat         x          y
#> 1 139.767 35.681  205212.3  -199413.7
#> 2 127.681 26.212 -394918.6   529024.8
#> 3 142.191 27.094  466806.8 -1141584.2
jpmap_transform(places, output_names = c("x", "y"), ogasawara = FALSE)
#>       lon    lat         x          y
#> 1 139.767 35.681  205212.3  -199413.7
#> 2 127.681 26.212 -394918.6   529024.8
#> 3 142.191 27.094  466806.8 -1141584.2
```
