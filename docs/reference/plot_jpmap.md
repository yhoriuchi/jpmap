# Plot a Japan Map

Plots Japan prefecture or municipal boundaries using `ggplot2`.

## Usage

``` r
plot_jpmap(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data = data.frame(),
  values = NULL,
  labels = FALSE,
  label_color = "black",
  data_year = NULL,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE,
  territorial_disputes = FALSE,
  disputed_fill = "#F6C85F",
  disputed_color = "#2C2A29",
  disputed_linewidth = 0.35,
  disputed_dots = TRUE,
  disputed_dot_fill = "#2C2A29",
  disputed_dot_color = "white",
  disputed_dot_size = 1.25,
  disputed_dot_stroke = 0.2,
  inset_boxes = TRUE,
  inset_box_color = "grey50",
  inset_box_linewidth = 0.35,
  data_dir = NULL,
  xlim = NULL,
  ylim = NULL,
  x_breaks = ggplot2::waiver(),
  y_breaks = ggplot2::waiver(),
  x_labels = ggplot2::waiver(),
  y_labels = ggplot2::waiver(),
  fill = "grey92",
  color = "grey35",
  linewidth = 0.25,
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

  Optional data frame to join to the map.

- values:

  Column name in `data` to use as the fill variable.

- labels:

  Whether to draw region labels.

- label_color:

  Label text color.

- data_year:

  Boundary data year.

- inset:

  Inset behavior. Use `TRUE` to move both Okinawa and Ogasawara, `FALSE`
  for no movement, or a character vector containing `"okinawa"` and/or
  `"ogasawara"` to move selected island groups.

- okinawa:

  Whether Okinawa should be moved when `inset` includes it.

- ogasawara:

  Whether Ogasawara should be moved when `inset` includes it.

- territorial_disputes:

  Whether to include disputed-territory island/reef shapes. The default
  is `FALSE`. Use `TRUE` for all built-in shapes, or a character vector
  containing one or more of `"northern_territories"`,
  `"okinotorishima"`, `"senkaku"`, and `"takeshima"`.

- disputed_fill:

  Fill color for opt-in disputed-territory shapes.

- disputed_color:

  Outline color for opt-in disputed-territory shapes.

- disputed_linewidth:

  Line width for opt-in disputed-territory shapes.

- disputed_dots:

  Whether to draw dot markers on opt-in disputed-territory shapes.

- disputed_dot_fill:

  Fill color for disputed-territory dot markers.

- disputed_dot_color:

  Outline color for disputed-territory dot markers.

- disputed_dot_size:

  Size for disputed-territory dot markers.

- disputed_dot_stroke:

  Stroke width for disputed-territory dot markers.

- inset_boxes:

  Whether to draw boxes around transported Okinawa and Ogasawara insets.

- inset_box_color:

  Outline color for inset boxes.

- inset_box_linewidth:

  Line width for inset boxes.

- data_dir:

  Optional directory containing `jpmap_boundaries_YYYY.gpkg`.

- xlim, ylim:

  Optional longitude and latitude limits for the plot frame.

- x_breaks, y_breaks:

  Optional longitude and latitude axis breaks.

- x_labels, y_labels:

  Optional longitude and latitude axis labels.

- fill:

  Boundary fill color when `values` is not supplied.

- color:

  Boundary line color.

- linewidth:

  Boundary line width.

- ...:

  Additional arguments passed to
  [`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).

## Value

A `ggplot2` plot.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_jpmap("prefecture")
plot_jpmap("prefecture", ogasawara = FALSE)
plot_jpmap("prefecture", territorial_disputes = TRUE)
plot_jpmap(
  "prefecture",
  ogasawara = FALSE,
  xlim = c(122, 149),
  ylim = c(28.5, 47),
  x_breaks = seq(125, 145, 5),
  y_breaks = seq(30, 45, 5)
)
plot_jpmap("prefecture", inset_boxes = FALSE)
plot_jpmap("municipality", include = "Okinawa")
} # }
```
