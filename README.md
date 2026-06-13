<div align="center">

<img src="man/figures/logo.png" width="150" height="150" alt="jpmap logo" />

### jpmap: Japan maps with visible island insets

</div>

---

`jpmap` is an R package for drawing maps of Japan with an API modeled after
[`usmap`](https://usmap.dev/).

The package is designed for maps where the main islands, Okinawa, and
Ogasawara can be seen together in one plotting frame.

Inset behavior is selectable: use `inset = TRUE` for both Okinawa and
Ogasawara, `inset = FALSE` for a literal projected map, or values such as
`inset = "okinawa"` to transport only selected island groups. You can also use
`okinawa = FALSE` or `ogasawara = FALSE`. `plot_jpmap()` draws inset boxes by
default; set `inset_boxes = FALSE` to remove them.

## Installation

Install the development version from GitHub:

```r
install.packages("remotes")
remotes::install_github("yhoriuchi/jpmap")
```

## Core Workflow

```r
library(jpmap)

plot_jpmap("prefecture")
plot_jpmap("municipality", include = "Okinawa")
```

## Articles

Start with these pages:

- [Introduction](articles/getting-started.html)
- [Download Boundary Data](articles/download-boundary-data.html)
- [Import Boundary Data](articles/import-boundary-data.html)
- [Transform Data](articles/transform-data.html)
- [Okinawa and Ogasawara Insets](articles/inset-options.html)

Then use the plotting tutorials:

- [Plot Prefectural Choropleth Maps](articles/prefectural-choropleths.html)
- [Plot Prefectural Point Maps](articles/prefectural-point-maps.html)
- [Plot Municipal Choropleth Maps](articles/municipal-choropleths.html)
- [Plot Municipal Point Maps](articles/municipal-point-maps.html)

## Transform Point Data

Use `jpmap_transform()` to put user-supplied longitude and latitude data into
the same projected coordinate system used by `plot_jpmap()`.

```r
library(jpmap)

points <- data.frame(
  place = c("Tokyo", "Naha", "Ogasawara"),
  lon = c(139.767, 127.681, 142.191),
  lat = c(35.681, 26.212, 27.094)
)

jpmap_transform(points)
```

## Boundary Data

The installed package includes:

- all-prefecture example boundaries for Japan, based on Natural Earth Admin-1
  data;
- official MLIT N03 municipal boundaries for Okinawa Prefecture as of
  January 1, 2024.

Use the bundled Okinawa municipal data immediately:

```r
plot_jpmap("municipality", include = "Okinawa")
```

Nationwide municipal polygons are much larger and should be built locally from
Japan's official MLIT National Land Numerical Information N03 administrative
area data:

```r
jpmap_build_data(year = 2024)
jpmap_build_data(year = 2024, prefecture = "Ehime")
```

The generated file is written to `jpmap_data_dir()` by default and contains two
layers:

- `prefectures`
- `municipalities`

After data is available, `jp_map()` returns `sf` objects and `plot_jpmap()`
returns ordinary `ggplot2` maps. Users who already work with
[`jpndistrict`](https://github.com/uribo/jpndistrict) can also pass its `sf`
output through `jpmap_transform()`.

## Example Data

Two public-source sample datasets are included:

- `jp_prefecture_gdp`: 2021 prefecture GDP per capita values.
- `jp_us_military_bases`: selected U.S. military installations in Japan with
  coordinates, public approximate personnel figures where available, and
  row-level `source_url` links.
