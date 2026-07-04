# Draw an Interactive Japan Map with leaflet

`jp_map_leaflet()` creates a simple interactive web map from `jpmap`
boundaries. It uses literal longitude/latitude geography because Leaflet
web tiles expect WGS84 coordinates. Use
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
when you want the static Okinawa and Ogasawara inset layout.

## Usage

``` r
jp_map_leaflet(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data = data.frame(),
  values = NULL,
  by = NULL,
  data_year = NULL,
  territorial_disputes = TRUE,
  data_dir = NULL,
  palette = "Blues",
  fill = "grey92",
  color = "grey35",
  weight = 1,
  opacity = 1,
  fill_opacity = 0.75,
  na_color = "#D9D9D9",
  label = NULL,
  popup = NULL,
  tiles = TRUE,
  legend = TRUE,
  fit_bounds = TRUE,
  simplify_tolerance = NULL,
  disputed_fill = NULL,
  disputed_color = NULL,
  disputed_dots = FALSE,
  disputed_dot_radius = 5,
  ...
)
```

## Arguments

- regions:

  Boundary level: prefectures or municipalities.

- include:

  Regions to include by code, English name, or Japanese name.

- exclude:

  Regions to exclude by code, English name, or Japanese name.

- data:

  Optional data frame to join to the map before drawing.

- values:

  Optional column to use for polygon fill colors.

- by:

  Optional join column passed to
  [`jp_map_join()`](https://yhoriuchi.github.io/jpmap/reference/jp_map_join.md).

- data_year:

  Boundary data year. The newest appropriate available file is used by
  default.

- territorial_disputes:

  Whether to include disputed-territory island/reef shapes. Use `FALSE`
  to exclude them, or a selected character vector.

- data_dir:

  Optional directory containing `jpmap_boundaries_YYYY.gpkg`.

- palette:

  Palette name or color vector passed to Leaflet palette functions when
  `values` is supplied.

- fill:

  Polygon fill color used when `values` is `NULL`.

- color:

  Polygon outline color.

- weight:

  Polygon outline weight.

- opacity:

  Polygon outline opacity.

- fill_opacity:

  Polygon fill opacity.

- na_color:

  Fill color for missing `values`.

- label:

  `NULL` for default region labels, `FALSE` for no labels, a column
  name, or a character vector with one value per map row.

- popup:

  `NULL` for default popups, `FALSE` for no popups, a column name, or a
  character vector with one value per map row.

- tiles:

  Whether to add default OpenStreetMap tiles.

- legend:

  Whether to add a legend when `values` is supplied.

- fit_bounds:

  Whether to zoom the widget to the map bounds.

- simplify_tolerance:

  Optional tolerance passed to
  [`sf::st_simplify()`](https://r-spatial.github.io/sf/reference/geos_unary.html)
  before drawing polygons. This is useful for smaller website widgets.

- disputed_fill:

  Optional fill color for disputed-territory shapes. When `NULL`, the
  ordinary map fill is used.

- disputed_color:

  Optional outline color for disputed-territory shapes. When `NULL`, the
  ordinary map outline is used.

- disputed_dots:

  Whether to draw circle markers on disputed-territory shapes.

- disputed_dot_radius:

  Radius for disputed-territory circle markers.

- ...:

  Additional arguments passed to
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html).

## Value

A `leaflet` htmlwidget.

## Examples

``` r
if (requireNamespace("leaflet", quietly = TRUE) &&
    requireNamespace("dplyr", quietly = TRUE) &&
    nrow(available_jpmap_data()) > 0) {
  data("jp_prefecture_gdp")

  gdp <- jp_prefecture_gdp |>
    dplyr::select(pref_code, prefecture, gdp_per_capita_jpy)

  jp_map_leaflet(
    "prefecture",
    data = gdp,
    values = "gdp_per_capita_jpy",
    popup = "prefecture"
  )
}
```
