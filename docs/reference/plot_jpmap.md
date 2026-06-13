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
  data_dir = NULL,
  color = "white",
  linewidth = 0.2,
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

- data_dir:

  Optional directory containing `jpmap_boundaries_YYYY.gpkg`.

- color:

  Boundary line color.

- linewidth:

  Boundary line width.

- ...:

  Additional arguments passed to
  [`ggplot2::geom_sf()`](https://rdrr.io/pkg/ggplot2/man/ggsf.html).

## Value

A `ggplot2` plot.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_jpmap("prefectures")
plot_jpmap("prefectures", ogasawara = FALSE)
} # }
```
