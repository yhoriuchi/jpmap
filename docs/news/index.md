# Changelog

## jpmap 0.1.1

Minor CRAN resubmission update.

- Removed large boundary GeoPackage files from `jpmap` so the package
  now contains functionality only.
- Updated the package and website documentation to point users to the
  companion `jpmapdata` package or locally built MLIT N03 GeoPackage
  files for boundary data.
- Replaced relative README article links with absolute pkgdown URLs.
- Reduced the source tarball size substantially for CRAN resubmission.

## jpmap 0.1.0

Initial CRAN submission.

- Added a `usmap`-style API for Japan maps:
  [`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jp_map_join()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_join.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md),
  and
  [`jpmap_crs()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_crs.md).
- Added support for prefecture and municipal boundary layers.
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
