# Retrieve Disputed-Territory Island And Reef Shapes

Returns cartographic island/reef shapes for disputed territories or
disputed maritime/EEZ-status areas discussed in Japan
territorial-dispute references. These geometries are intentionally
separate from the MLIT N03 administrative boundary data and are not
authoritative legal boundary polygons.

## Usage

``` r
jp_disputed_territories(
  territorial_disputes = TRUE,
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE
)
```

## Arguments

- territorial_disputes:

  Which disputed-territory shapes to include. Use `TRUE` for all
  built-in shapes, `FALSE` for none, or a character vector containing
  one or more of `"northern_territories"`, `"okinotorishima"`,
  `"senkaku"`, and `"takeshima"`. Common aliases such as `"kuril"`,
  `"liancourt"`, `"dokdo"`, and `"diaoyu"` are also accepted.

- regions:

  Boundary level whose columns should be mirrored: prefectures or
  municipalities.

- inset:

  Inset behavior. Use `TRUE` to move Okinawa and Ogasawara, `FALSE` for
  literal projected locations, or a character vector containing
  `"okinawa"` and/or `"ogasawara"`.

- okinawa:

  Whether Okinawa should be moved when `inset` includes it.

- ogasawara:

  Whether Ogasawara should be moved when `inset` includes it.

## Value

An `sf` data frame.

## Source

Territory list based on
<https://en.wikipedia.org/wiki/Territorial_disputes_of_Japan>. Shapes
are derived from Natural Earth 1:10m land polygons and OpenStreetMap
geometry.

## Examples

``` r
if (FALSE) { # \dontrun{
jp_disputed_territories()
jp_disputed_territories(c("senkaku", "takeshima"))
} # }
```
