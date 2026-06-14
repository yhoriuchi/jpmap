# Plot Municipal Point Maps

This example plots selected U.S. base coordinates on Okinawa municipal
boundaries. The map uses one point variable: `branch`. The figure
focuses on Okinawa Island so the small municipal polygons and base
points are legible.

``` r

library(tidyverse)
library(jpmap)

okinawa_bases <- jp_us_military_bases |>
  filter(
    prefecture == "Okinawa",
    base != "Okinawa U.S. military facilities"
  )

okinawa_main_island <- c(
  "那覇市", "宜野湾市", "浦添市", "名護市", "糸満市", "沖縄市",
  "豊見城市", "うるま市", "南城市", "国頭村", "大宜味村", "東村",
  "今帰仁村", "本部町", "恩納村", "宜野座村", "金武町", "読谷村",
  "嘉手納町", "北谷町", "北中城村", "中城村", "西原町", "与那原町",
  "南風原町", "八重瀬町"
)
okinawa_main_island_min_area <- 5e6
keep_okinawa_main_island <- function(map) {
  filtered <- map |>
    filter(municipality_ja %in% okinawa_main_island)

  filtered |>
    mutate(area_m2 = as.numeric(sf::st_area(filtered))) |>
    filter(area_m2 >= okinawa_main_island_min_area) |>
    select(-area_m2)
}

okinawa_main_map <- jp_map("municipality", include = "Okinawa", inset = FALSE) |>
  keep_okinawa_main_island()

okinawa_bases_xy <- okinawa_bases |>
  jpmap_transform(output_names = c("x", "y"), inset = FALSE)
```

``` r

ggplot(okinawa_main_map) +
  geom_sf(
    fill = "grey92",
    color = "grey35",
    linewidth = 0.12
  ) +
  coord_sf(
    crs = jpmap_crs(),
    datum = sf::st_crs(4326)
  ) +
  geom_point(
    data = okinawa_bases_xy,
    aes(x = x, y = y, color = branch),
    size = 2.6,
    alpha = 0.9
  ) +
  scale_color_manual(
    values = c(
      "Air Force" = "#005BAC",
      "Army" = "#2C2A29",
      "Marine Corps" = "#7899D4",
      "Navy" = "#001040"
    ),
    name = "Branch"
  ) +
  labs(
    title = "Selected U.S. base points on Okinawa Island",
    caption = "Boundary: MLIT N03 administrative area data, January 1, 2024."
  ) +
  theme_gray() +
  theme(
    axis.title = element_blank(),
    panel.grid.minor = element_blank(),
    legend.background = element_rect(fill = "white", color = NA),
    plot.title = element_text(face = "bold", color = "#001040"),
    plot.caption = element_text(color = "#2C2A29", hjust = 0, size = 8)
  )
```

![](municipal-point-maps_files/figure-html/municipal-base-points-1.png)

The only mapped base variable is `branch`. Point size, alpha, and
boundary style are fixed.
