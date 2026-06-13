# Introduction

`jpmap` follows the same basic workflow as `usmap`: plot a map, get the
map data, and transform your own coordinates into the same coordinate
system.

Install the development version from GitHub:

``` r

install.packages("remotes")
remotes::install_github("yhoriuchi/jpmap")
```

``` r

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

places <- data.frame(
  place = c("Tokyo", "Naha", "Ogasawara"),
  lon = c(139.767, 127.681, 142.191),
  lat = c(35.681, 26.212, 27.094)
)

jpmap_transform(places, output_names = c("x", "y"))
#>       place     lon    lat         x         y
#> 1     Tokyo 139.767 35.681  205212.3 -199413.7
#> 2      Naha 127.681 26.212 -463547.6  529529.7
#> 3 Ogasawara 142.191 27.094  324501.9 -432790.6
```

By default, the transform moves Okinawa and Ogasawara into visible inset
locations. Use `inset = FALSE` for a literal projected map, or pass a
character vector such as `inset = "okinawa"` to transport only selected
island groups. You can also use `okinawa = FALSE` or
`ogasawara = FALSE`.
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
draws inset boxes by default; set `inset_boxes = FALSE` to remove them.
