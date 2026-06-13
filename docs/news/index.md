# Changelog

## jpmap 0.0.0.9000

Initial development version.

- Added a `usmap`-style API for Japan maps:
  [`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md),
  [`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md),
  [`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md),
  and
  [`jpmap_crs()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_crs.md).
- Added support for prefecture and municipal boundary layers.
- Added inset transformations for Okinawa and Ogasawara, with support
  for selecting which island groups to transport via `inset`.
- Added pkgdown website configuration using Florida State University
  garnet and gold colors.
- Added sample GDP-per-capita and U.S. military base datasets plus a
  website vignette showing both on a Japan map. The military-base
  example now separates installation locations from regional,
  command-level, and base-specific public personnel figures.
