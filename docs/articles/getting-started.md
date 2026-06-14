# Introduction

`jpmap` follows the same basic workflow as `usmap`: plot a map, get the
map data, and transform your own coordinates into the same coordinate
system.

Install the development version from GitHub:

``` r

install.packages("remotes")
remotes::install_github("yhoriuchi/jpmap")
```

Boundary GeoPackages are large. Install the companion `jpmapdata`
package when you want ready-to-use boundaries, or build local files with
[`jpmap_build_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md).

``` r

library(tidyverse)
library(jpmap)
```

The main plotting function is
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md).
These two calls draw empty maps without adding data, labels, colors, or
other options.

``` r

plot_jpmap("prefecture")
plot_jpmap("municipality", include = "Okinawa")
```

The data function is
[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md),
which returns an `sf` object.

``` r

prefectures <- jp_map("prefecture")
okinawa_municipalities <- jp_map("municipality", include = "Okinawa")
```

The transform function is
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md).

``` r

places <- tribble(
  ~place, ~lon, ~lat,
  "Tokyo", 139.767, 35.681,
  "Naha", 127.681, 26.212,
  "Ogasawara", 142.191, 27.094
)

places |>
  jpmap_transform(output_names = c("x", "y"))
#> # A tibble: 3 × 5
#>   place       lon   lat        x        y
#>   <chr>     <dbl> <dbl>    <dbl>    <dbl>
#> 1 Tokyo      140.  35.7  205212. -199414.
#> 2 Naha       128.  26.2 -683245.  657517.
#> 3 Ogasawara  142.  27.1  537219. -578089.
```

By default, the transform moves Okinawa and Ogasawara into visible inset
locations. Use `inset = FALSE` for a literal projected map, or pass a
character vector such as `inset = "okinawa"` to transport only selected
island groups. You can also use `okinawa = FALSE` or
`ogasawara = FALSE`.
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
draws inset boxes by default; set `inset_boxes = FALSE` to remove them.
Use `xlim`, `ylim`, `x_breaks`, `y_breaks`, `x_labels`, and `y_labels`
when you want to customize the displayed longitude/latitude frame.
