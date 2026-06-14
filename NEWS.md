# jpmap 0.1.1

Initial CRAN release.

- Added a `usmap`-style API for Japan maps: `jp_map()`, `plot_jpmap()`,
  `jp_map_join()`, `plot_jpmap()`, `jpmap_transform()`, and `jpmap_crs()`.
- Added support for prefecture and municipal boundary layers through a companion
  data package or locally built MLIT N03 GeoPackage files.
- Added inset transformations and controls for Okinawa and Ogasawara, including
  true-coordinate graticules inside inset boxes and axis-limit controls.
- Added disputed-territory island/reef shapes with controls such as
  `territorial_disputes = FALSE`.
- Added `jp_map_leaflet()` for interactive web maps.
- Added sample GDP-per-capita and U.S. military base datasets, plus focused
  vignettes using tidyverse-style examples with the native R pipe.
- Added a pkgdown website and Samurai Blue logo/theme.
