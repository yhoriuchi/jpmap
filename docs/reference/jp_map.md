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
  territorial_disputes = TRUE,
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

  Boundary data year. The newest appropriate available file is used by
  default. For example, national prefecture maps prefer a national file,
  while one-prefecture municipal requests can use a matching prefecture
  file.

- inset:

  Inset behavior. Use `TRUE` to move both Okinawa and Ogasawara, `FALSE`
  for no movement, or a character vector containing `"okinawa"` and/or
  `"ogasawara"` to move selected island groups.

- okinawa:

  Whether Okinawa should be moved when `inset` includes it.

- ogasawara:

  Whether Ogasawara should be moved when `inset` includes it.

- territorial_disputes:

  Whether to include disputed-territory island/reef shapes. The default
  is `TRUE`. Use `FALSE` to exclude them, or a character vector
  containing one or more of `"northern_territories"`,
  `"okinotorishima"`, `"senkaku"`, and `"takeshima"`.

- data_dir:

  Optional directory containing `jpmap_boundaries_YYYY.gpkg`.

## Value

An `sf` data frame.

## Examples

``` r
if (FALSE) { # \dontrun{
jp_map("prefectures")
jp_map("prefectures", okinawa = FALSE)
jp_map("prefectures", territorial_disputes = FALSE)
jp_map("municipalities", include = "Okinawa")
jp_map("prefecture")
jp_map("municipality", include = "Okinawa")
} # }
```
