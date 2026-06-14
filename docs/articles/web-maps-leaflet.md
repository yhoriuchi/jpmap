# Interactive Web Maps with leaflet

[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
is the right tool for static maps with Okinawa and Ogasawara insets.
Leaflet is different: web tiles expect true longitude and latitude, so
[`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
uses literal WGS84 geography rather than the inset layout.

Install `leaflet` before running these examples:

``` r

install.packages("leaflet")
```

## Prefecture Choropleth

``` r

library(tidyverse)
library(jpmap)

gdp <- jp_prefecture_gdp |>
  select(pref_code, prefecture, gdp_per_capita_jpy)

jp_map_leaflet(
  "prefecture",
  data = gdp,
  values = "gdp_per_capita_jpy",
  palette = "Blues",
  popup = "prefecture",
  simplify_tolerance = 0.03
)
```

[`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
uses the same data-join logic as
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md).
If your data has numeric prefecture codes such as `1`, `2`, and `47`,
`jpmap` can still match them to map codes such as `"01"`, `"02"`, and
`"47"`.

## Disputed-Territory Layer

For web maps, use `territorial_disputes = FALSE` to exclude
disputed-territory shapes, or highlight them explicitly.

``` r

jp_map_leaflet(
  "prefecture",
  fill = "grey92",
  disputed_fill = "#005BAC",
  disputed_color = "#001040",
  disputed_dots = TRUE
)
```

Small disputed-territory polygons can be hard to click at a national
zoom level, so `disputed_dots = TRUE` can add circle markers when you
choose to emphasize them.

## Municipal Map

Okinawa municipal data can be used when the corresponding boundary file
is available through `jpmapdata` or
[`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md).

``` r

jp_map_leaflet(
  "municipality",
  include = "Okinawa",
  fill = "grey92",
  color = "white",
  weight = 0.8,
  popup = "municipality_ja"
)
```

For other prefectures or nationwide municipal maps, build local MLIT N03
data first with
[`jpmap_build_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md).

## Quarto, pkgdown, And Shiny

Leaflet widgets returned by
[`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
are ordinary htmlwidgets. You can place them directly in Quarto
documents, pkgdown articles, R Markdown reports, and Shiny UI outputs.

For Shiny, build the widget inside `renderLeaflet()`:

``` r

output$japan_map <- leaflet::renderLeaflet({
  jp_map_leaflet(
    "prefecture",
    data = jp_prefecture_gdp,
    values = "gdp_per_capita_jpy"
  )
})
```

Use
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
when the map needs the compact inset layout. Use
[`jp_map_leaflet()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_leaflet.md)
when users need pan, zoom, labels, popups, and website interaction.
