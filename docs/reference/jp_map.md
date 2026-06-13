# Retrieve Japan Map Data

Reads Japan administrative boundary data and returns an `sf` object.

## Usage

``` r
jp_map(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data_year = NULL,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE,
  data_dir = NULL
)
```

## Arguments

- regions:

  Boundary level: prefectures or municipalities.

- include:

  Regions to include by code, English name, or Japanese name.

- exclude:

  Regions to exclude by code, English name, or Japanese name.

- data_year:

  Boundary data year. The newest available year is used by default.

- inset:

  Inset behavior. Use `TRUE` to move both Okinawa and Ogasawara, `FALSE`
  for no movement, or a character vector containing `"okinawa"` and/or
  `"ogasawara"` to move selected island groups.

- okinawa:

  Whether Okinawa should be moved when `inset` includes it.

- ogasawara:

  Whether Ogasawara should be moved when `inset` includes it.

- data_dir:

  Optional directory containing `jpmap_boundaries_YYYY.gpkg`.

## Value

An `sf` data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
jp_map("prefectures")
jp_map("prefectures", okinawa = FALSE)
jp_map("municipalities", include = "Okinawa")
} # }
```
