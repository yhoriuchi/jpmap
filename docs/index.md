![jpmap logo](reference/figures/logo.png)

### jpmap: Japan maps with visible island insets

------------------------------------------------------------------------

`jpmap` is an R package for drawing maps of Japan with an API modeled
after [`usmap`](https://usmap.dev/).

The package is designed for maps where the main islands, Okinawa, and
Ogasawara can be seen together in one plotting frame.

Inset behavior is selectable: use `inset = TRUE` for both Okinawa and
Ogasawara, `inset = FALSE` for a literal projected map, or values such
as `inset = "okinawa"` to transport only selected island groups. You can
also use `okinawa = FALSE` or `ogasawara = FALSE`.
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
draws inset boxes by default; set `inset_boxes = FALSE` to remove them.

## Core Workflow

``` r

library(jpmap)

plot_jpmap("prefectures")
plot_jpmap("municipalities", include = "Okinawa")
```

## Transform Point Data

Use
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
to put user-supplied longitude and latitude data into the same projected
coordinate system used by
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md).

``` r

library(jpmap)

points <- data.frame(
  place = c("Tokyo", "Naha", "Ogasawara"),
  lon = c(139.767, 127.681, 142.191),
  lat = c(35.681, 26.212, 27.094)
)

jpmap_transform(points)
```

## Boundary Data

The package expects administrative boundary data in GeoPackage files
named `jpmap_boundaries_YYYY.gpkg`. You can build one from Japan’s MLIT
National Land Numerical Information N03 administrative area data:

``` r

jpmap_build_data(year = 2024)
jpmap_build_data(year = 2024, prefecture = "Ehime")
```

The 2024 N03 source archive is large, about 583 MB, so this is an
explicit user-run step rather than something the package does during
installation. The `prefecture` argument downloads a smaller official
prefecture-specific N03 file.

The generated file is written to
[`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
by default and contains two layers:

- `prefectures`
- `municipalities`

After data is available,
[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md)
returns `sf` objects and
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
returns ordinary `ggplot2` maps.

The package also includes a small Natural Earth prefecture layer and an
Okinawa municipal layer from Geoshape for examples and website figures.
Nationwide detailed municipal boundaries still require
[`jpmap_build_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md).
This keeps the installed package small while still supporting full
municipal maps when users explicitly build or supply the larger boundary
data. Users who already work with
[`jpndistrict`](https://github.com/uribo/jpndistrict) can also pass its
`sf` output through
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md).

## Example Data

Two public-source sample datasets are included:

- `jp_prefecture_gdp`: 2021 prefecture GDP per capita values.
- `jp_us_military_bases`: selected U.S. military installations in Japan
  with coordinates and public approximate personnel figures where
  available. See the “U.S. Military Bases and Prefecture GDP” article
  for an example that keeps installation locations separate from
  regional or command-level personnel figures.

## Website

Build the pkgdown site locally with:

``` r

pkgdown::build_site()
```
