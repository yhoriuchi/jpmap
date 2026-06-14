# Changelog

## jpmap 0.1.0

Initial CRAN release.

- Added a `usmap`-style API for Japan maps:
  [`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jp_map_join()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_join.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md),
  and
  [`jpmap_crs()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_crs.md).
- Added support for prefecture and municipal boundary layers, including
  bundled MLIT N03 2024 municipal boundaries for Okinawa Prefecture.
- Added inset transformations and controls for Okinawa and Ogasawara,
  including true-coordinate graticules inside inset boxes and axis-limit
  controls.
- Added disputed-territory island/reef shapes, included quietly by
  default and removable with `territorial_disputes = FALSE`.
- Added
  [`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
  for interactive web maps.
- Added sample GDP-per-capita and U.S. military base datasets, plus
  focused vignettes using tidyverse-style examples with the native R
  pipe.
- Added a pkgdown website and Samurai Blue logo/theme.
