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
if (requireNamespace("tibble", quietly = TRUE)) {
  places <- tibble::tribble(
    ~place, ~lon, ~lat,
    "Tokyo", 139.767, 35.681,
    "Naha", 127.681, 26.212,
    "Ogasawara", 142.191, 27.094
  )

  places |>
    jpmap_transform(output_names = c("x", "y"))
  places |>
    jpmap_transform(output_names = c("x", "y"), inset = "okinawa")
  places |>
    jpmap_transform(output_names = c("x", "y"), ogasawara = FALSE)
}
#> # A tibble: 3 × 5
#>   place       lon   lat        x         y
#>   <chr>     <dbl> <dbl>    <dbl>     <dbl>
#> 1 Tokyo      140.  35.7  205212.  -199414.
#> 2 Naha       128.  26.2 -683245.   657517.
#> 3 Ogasawara  142.  27.1  466807. -1141584.
```
