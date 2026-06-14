# Changelog

## jpmap 0.1.1

Initial CRAN release.

- Added a `usmap`-style API for Japan maps:
  [`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jp_map_join()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_join.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md),
  and
  [`jpmap_crs()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_crs.md).
- Added support for prefecture and municipal boundary layers through a
  companion data package or locally built MLIT N03 GeoPackage files.
- Added inset transformations and controls for Okinawa and Ogasawara,
  including true-coordinate graticules inside inset boxes and axis-limit
  controls.
- Added disputed-territory island/reef shapes with controls such as
  `territorial_disputes = FALSE`.
- Added
  [`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
  for interactive web maps.
- Added sample GDP-per-capita and U.S. military base datasets, plus
  focused vignettes using tidyverse-style examples with the native R
  pipe.
- Added a pkgdown website and Samurai Blue logo/theme.
