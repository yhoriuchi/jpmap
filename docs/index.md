![jpmap logo](reference/figures/logo.png)

[![R-CMD-check](https://github.com/yhoriuchi/jpmap/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yhoriuchi/jpmap/actions/workflows/R-CMD-check.yaml)

### jpmap: Japan maps with visible island insets

------------------------------------------------------------------------

`jpmap` is an R package for drawing maps of Japan with an API modeled
after [`usmap`](https://usmap.dev/).

The package is designed to be the everyday Japan-map workflow for R
users: request a map, join ordinary tabular data, and publish a static
or interactive figure without writing one-off GIS scripts.

Inset behavior is selectable: use `inset = TRUE` for both Okinawa and
Ogasawara, `inset = FALSE` for a literal projected map, or values such
as `inset = "okinawa"` to transport only selected island groups. You can
also use `okinawa = FALSE` or `ogasawara = FALSE`.
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
draws inset boxes by default; set `inset_boxes = FALSE` to remove them.

Use `territorial_disputes = FALSE` to exclude areas discussed in Japan
territorial-dispute references, or pass a subset such as `"senkaku"` or
`"takeshima"`.

For website maps,
[`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
returns a Leaflet htmlwidget using literal longitude/latitude geography.

## Installation

Install the development version from GitHub:

``` r

install.packages("remotes")
remotes::install_github("yhoriuchi/jpmap")
```

## Core Workflow

``` r

library(tidyverse)
library(jpmap)

plot_jpmap("prefecture")
plot_jpmap("municipality", include = "Okinawa")
plot_jpmap("prefecture", territorial_disputes = FALSE)

gdp <- jp_prefecture_gdp |>
  select(pref_code, gdp_per_capita_jpy)

jp_map("prefecture") |>
  jp_map_join(gdp, by = "pref_code")
```

## Articles

Start with these pages:

- [Introduction](https://yhoriuchi.github.io/jpmap/articles/getting-started.html)
- [Related
  Packages](https://yhoriuchi.github.io/jpmap/articles/related-packages.html)
- [Boundary Data
  Policy](https://yhoriuchi.github.io/jpmap/articles/boundary-data-policy.html)
- [Download Boundary
  Data](https://yhoriuchi.github.io/jpmap/articles/download-boundary-data.html)
- [Import Boundary
  Data](https://yhoriuchi.github.io/jpmap/articles/import-boundary-data.html)
- [Transform
  Data](https://yhoriuchi.github.io/jpmap/articles/transform-data.html)
- [Okinawa and Ogasawara
  Insets](https://yhoriuchi.github.io/jpmap/articles/inset-options.html)
- [Interactive Web Maps with
  leaflet](https://yhoriuchi.github.io/jpmap/articles/web-maps-leaflet.html)

Then use the plotting tutorials:

- [Plot Prefectural Choropleth
  Maps](https://yhoriuchi.github.io/jpmap/articles/prefectural-choropleths.html)
- [Plot Prefectural Point
  Maps](https://yhoriuchi.github.io/jpmap/articles/prefectural-point-maps.html)
- [Plot Municipal Choropleth
  Maps](https://yhoriuchi.github.io/jpmap/articles/municipal-choropleths.html)
- [Plot Municipal Point
  Maps](https://yhoriuchi.github.io/jpmap/articles/municipal-point-maps.html)

## Transform Point Data

Use
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
to put user-supplied longitude and latitude data into the same projected
coordinate system used by
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md).

``` r

library(tidyverse)
library(jpmap)

points <- tribble(
  ~place, ~lon, ~lat,
  "Tokyo", 139.767, 35.681,
  "Naha", 127.681, 26.212,
  "Ogasawara", 142.191, 27.094
)

points |>
  jpmap_transform()
```

## Boundary Data

The installed package includes:

- all-prefecture example boundaries for Japan, based on Natural Earth
  Admin-1 data;
- official MLIT N03 municipal boundaries for Okinawa Prefecture as of
  January 1, 2024.

Use the bundled Okinawa municipal data immediately:

``` r

plot_jpmap("municipality", include = "Okinawa")
```

Nationwide municipal polygons are much larger and should be built
locally from Japan’s official MLIT National Land Numerical Information
N03 administrative area data:

``` r

jpmap_build_data(year = 2024)
jpmap_build_data(year = 2024, prefecture = "Ehime")
```

The generated file is written to
[`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
by default and contains two layers:

- `prefectures`
- `municipalities`

After data is available,
[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md)
returns `sf` objects and
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
returns ordinary `ggplot2` maps. Users who already work with
[`jpndistrict`](https://github.com/uribo/jpndistrict) can also pass its
`sf` output through
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md).

## Example Data

Two public-source sample datasets are included:

- `jp_prefecture_gdp`: 2021 prefecture GDP per capita values.
- `jp_us_military_bases`: selected U.S. military installations in Japan
  with coordinates, public approximate personnel figures where
  available, and row-level `source_url` links.
