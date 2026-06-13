<div align="center">

<img src="man/figures/logo.png" width="150" height="150" alt="jpmap logo" />

### jpmap: Japan maps with visible island insets

</div>

---

`jpmap` is an R package for drawing maps of Japan with an API modeled after
[`usmap`](https://usmap.dev/).

The package is designed for maps where the main islands, Okinawa, and
Ogasawara can be seen together in one plotting frame.

## Core Workflow

```r
library(jpmap)

plot_jpmap("prefectures")
plot_jpmap("municipalities", include = "Tokyo")
```

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

The package expects administrative boundary data in GeoPackage files named
`jpmap_boundaries_YYYY.gpkg`. You can build one from Japan's MLIT National Land
Numerical Information N03 administrative area data:

```r
jpmap_build_data(year = 2024)
```

The 2024 N03 source archive is large, about 583 MB, so this is an explicit
user-run step rather than something the package does during installation.

The generated file is written to `jpmap_data_dir()` by default and contains two
layers:

- `prefectures`
- `municipalities`

After data is available, `jp_map()` returns `sf` objects and `plot_jpmap()`
returns ordinary `ggplot2` maps.

## Website

Build the pkgdown site locally with:

```r
pkgdown::build_site()
```
