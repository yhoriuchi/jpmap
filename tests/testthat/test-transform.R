skip_if_no_jpmap_boundaries <- function() {
  testthat::skip_if(
    nrow(available_jpmap_data()) == 0,
    "jpmap boundary data unavailable"
  )
}

test_that("jpmap_crs returns an sf CRS", {
  expect_s3_class(jpmap_crs(), "crs")
  expect_false(is.na(jpmap_crs()))
})

test_that("data frames can be transformed", {
  places <- data.frame(
    name = c("Tokyo", "Naha", "Ogasawara"),
    lon = c(139.767, 127.681, 142.191),
    lat = c(35.681, 26.212, 27.094)
  )

  out <- jpmap_transform(places, output_names = c("x", "y"))
  expect_true(all(c("x", "y") %in% names(out)))
  expect_true(all(is.finite(out$x)))
  expect_true(all(is.finite(out$y)))
  expect_equal(out$name, places$name)
})

test_that("inset can select island groups", {
  places <- data.frame(
    name = c("Naha", "Ogasawara"),
    lon = c(127.681, 142.191),
    lat = c(26.212, 27.094)
  )

  both <- jpmap_transform(places, output_names = c("x", "y"))
  okinawa_only <- jpmap_transform(places, output_names = c("x", "y"), inset = "okinawa")
  ogasawara_only <- jpmap_transform(places, output_names = c("x", "y"), inset = "ogasawara")
  without_okinawa <- jpmap_transform(places, output_names = c("x", "y"), okinawa = FALSE)
  without_ogasawara <- jpmap_transform(places, output_names = c("x", "y"), ogasawara = FALSE)
  literal <- jpmap_transform(places, output_names = c("x", "y"), inset = FALSE)

  expect_equal(okinawa_only$x[places$name == "Naha"], both$x[places$name == "Naha"])
  expect_equal(okinawa_only$x[places$name == "Ogasawara"], literal$x[places$name == "Ogasawara"])
  expect_equal(ogasawara_only$x[places$name == "Naha"], literal$x[places$name == "Naha"])
  expect_equal(ogasawara_only$x[places$name == "Ogasawara"], both$x[places$name == "Ogasawara"])
  expect_equal(without_okinawa$x[places$name == "Naha"], literal$x[places$name == "Naha"])
  expect_equal(without_okinawa$x[places$name == "Ogasawara"], both$x[places$name == "Ogasawara"])
  expect_equal(without_ogasawara$x[places$name == "Naha"], both$x[places$name == "Naha"])
  expect_equal(without_ogasawara$x[places$name == "Ogasawara"], literal$x[places$name == "Ogasawara"])
  expect_error(jpmap_transform(places, inset = "hokkaido"), "one or more of")
  expect_error(jpmap_transform(places, okinawa = NA), "`okinawa` must be TRUE or FALSE", fixed = TRUE)
})

test_that("sf geometries can be transformed", {
  pts <- sf::st_as_sf(
    data.frame(lon = c(139.767, 127.681), lat = c(35.681, 26.212)),
    coords = c("lon", "lat"),
    crs = 4326
  )

  out <- jpmap_transform(pts)
  expect_s3_class(out, "sf")
  expect_equal(sf::st_crs(out), jpmap_crs())
})

test_that("missing map data gives a helpful error", {
  empty_dir <- tempfile("jpmap-empty-")
  dir.create(empty_dir)

  expect_error(
    jp_map(data_dir = empty_dir),
    "No jpmap boundary data was found"
  )
})

test_that("boundary data are available from jpmapdata or local files", {
  skip_if_no_jpmap_boundaries()

  available <- available_jpmap_data()
  expect_true(any(available$year == 2021))
  expect_true(any(available$year == 2024 & available$pref_code == "47"))
  expect_true(all(nzchar(available$source)))

  map <- jp_map("prefecture")
  expect_s3_class(map, "sf")
  expect_equal(nrow(map), 51)
  expect_equal(nrow(jp_map("prefecture", territorial_disputes = FALSE)), 47)
})

test_that("disputed-territory shapes can be included and excluded", {
  skip_if_no_jpmap_boundaries()

  default_map <- jp_map("prefecture")
  default_literal <- jp_map("prefecture", inset = FALSE)
  excluded_map <- jp_map("prefecture", territorial_disputes = FALSE)
  disputed_only <- jp_disputed_territories()
  senkaku_only <- jp_disputed_territories("senkaku")
  senkaku_literal <- jp_disputed_territories("senkaku", inset = FALSE)

  expect_equal(nrow(default_map), 51)
  expect_equal(sum(default_map$is_disputed_territory %in% TRUE), 4)
  expect_equal(nrow(excluded_map), 47)
  expect_false("is_disputed_territory" %in% names(excluded_map))
  expect_true(any(lengths(sf::st_intersects(default_literal, senkaku_literal)) > 0))
  expect_equal(nrow(jp_map("prefecture", territorial_disputes = "senkaku")), 48)
  expect_false(any(sf::st_is_empty(default_map[default_map$is_disputed_territory %in% TRUE, ])))
  expect_equal(
    sort(unique(default_map$dispute_region[default_map$is_disputed_territory %in% TRUE])),
    c("northern_territories", "okinotorishima", "senkaku", "takeshima")
  )

  expect_s3_class(disputed_only, "sf")
  expect_equal(nrow(disputed_only), 4)
  expect_true(all(disputed_only$is_disputed_territory))
  expect_true(all(grepl("POLYGON", as.character(sf::st_geometry_type(disputed_only)))))
  expect_true(all(c("source", "source_url") %in% names(disputed_only)))
  expect_equal(senkaku_only$dispute_region, "senkaku")
  expect_equal(nrow(jp_disputed_territories(FALSE)), 0)
  expect_error(jp_disputed_territories("atlantis"), "`territorial_disputes` must be TRUE")
  plot <- plot_jpmap("prefecture")
  expect_s3_class(plot, "ggplot")
  expect_true(length(plot$layers) >= 6)
  expect_s3_class(
    plot_jpmap("prefecture", disputed_fill = "#005BAC", disputed_dots = TRUE),
    "ggplot"
  )
  expect_error(
    plot_jpmap("prefecture", disputed_dots = NA),
    "`disputed_dots` must be TRUE or FALSE",
    fixed = TRUE
  )
})

test_that("Okinawa municipalities are available when boundary data are installed", {
  skip_if_no_jpmap_boundaries()

  map <- jp_map("municipality", include = "Okinawa", inset = FALSE)
  admin_map <- map[!(map$is_disputed_territory %in% TRUE), , drop = FALSE]
  disputed_map <- map[map$is_disputed_territory %in% TRUE, , drop = FALSE]

  expect_s3_class(map, "sf")
  expect_true(nrow(admin_map) > 41)
  expect_true(all(admin_map$prefecture == "Okinawa"))
  expect_true(all(admin_map$pref_code == "47"))
  expect_true(all(admin_map$municipality_code != ""))
  expect_equal(disputed_map$dispute_region, "senkaku")
})

test_that("filtered municipality plots use a local default frame", {
  skip_if_no_jpmap_boundaries()

  plot <- plot_jpmap("municipality", include = "Okinawa")
  explicit_inset <- plot_jpmap("municipality", include = "Okinawa", inset = TRUE)

  expect_s3_class(plot, "ggplot")
  expect_null(plot$coordinates$limits$x)
  expect_null(plot$coordinates$limits$y)
  expect_true(length(plot$layers) < length(explicit_inset$layers))
  expect_false(is.null(explicit_inset$coordinates$limits$x))
  expect_false(is.null(explicit_inset$coordinates$limits$y))
})

test_that("jp_map_join handles common Japan map keys safely", {
  skip_if_no_jpmap_boundaries()

  map <- jp_map("prefecture")
  numeric_codes <- data.frame(
    pref_code = seq_len(47),
    value = seq_len(47)
  )
  named_codes <- data.frame(
    code = seq_len(47),
    named_value = seq_len(47) * 10
  )

  joined <- jp_map_join(map, numeric_codes, by = "pref_code")
  expect_equal(joined$value[joined$pref_code %in% "01"], 1)
  expect_equal(joined$value[joined$pref_code %in% "47"], 47)

  named_join <- jp_map_join(map, named_codes, by = c("pref_code" = "code"))
  expect_equal(named_join$named_value[named_join$pref_code %in% "01"], 10)
  expect_false("code" %in% names(named_join))

  duplicated_codes <- rbind(numeric_codes[1, ], numeric_codes[1, ])
  expect_error(
    jp_map_join(map, duplicated_codes, by = "pref_code"),
    "duplicate join keys",
    fixed = TRUE
  )
  expect_warning(
    jp_map_join(map, data.frame(pref_code = 99, value = 1), by = "pref_code"),
    "did not match the map"
  )
})

test_that("jp_map_leaflet reports missing optional dependency", {
  skip_if_no_jpmap_boundaries()

  if (requireNamespace("leaflet", quietly = TRUE)) {
    expect_s3_class(jp_map_leaflet("prefecture"), "leaflet")
  } else {
    expect_error(jp_map_leaflet("prefecture"), "requires the leaflet package")
  }
})

test_that("official N03 source URLs can target national or prefecture data", {
  expect_equal(
    n03_source_url(2024),
    "https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2024/N03-20240101_GML.zip"
  )
  expect_equal(
    n03_source_url(2024, "38"),
    "https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2024/N03-20240101_38_GML.zip"
  )
  expect_equal(prefecture_code_from_input("Ehime"), "38")
  expect_equal(prefecture_code_from_input("愛媛県"), "38")
  expect_equal(prefecture_code_from_input(47), "47")
  expect_error(prefecture_code_from_input("Atlantis"), "Unknown prefecture")
})

test_that("inset boxes are available for plot maps", {
  skip_if_no_jpmap_boundaries()

  boxes <- jpmap_inset_boxes(c("okinawa", "ogasawara"))
  graticules <- jpmap_inset_graticules(c("okinawa", "ogasawara"))
  plot <- plot_jpmap("prefectures", data_year = 2021, inset_boxes = FALSE)

  expect_s3_class(boxes, "sf")
  expect_equal(nrow(boxes), 2)
  expect_true(all(boxes$region %in% c("okinawa", "ogasawara")))
  for (box in sf::st_geometry(boxes)) {
    ring <- box[[1]]
    expect_equal(length(unique(ring[, 1])), 2)
    expect_equal(length(unique(ring[, 2])), 2)
  }
  expect_s3_class(graticules$lines, "sf")
  expect_s3_class(graticules$labels, "sf")
  expect_true(nrow(graticules$lines) > nrow(boxes))
  expect_true(all(graticules$lines$region %in% c("okinawa", "ogasawara")))
  expect_true(all(c("x", "y", "label", "hjust", "vjust") %in% names(graticules$labels)))
  expect_true(any(grepl("E$", graticules$labels$label)))
  expect_true(any(grepl("N$", graticules$labels$label)))
  expect_s3_class(plot, "ggplot")
  expect_s3_class(
    plot_jpmap(
      "prefectures",
      data_year = 2021,
      xlim = c(122, 149),
      ylim = c(28.5, 47),
      x_breaks = seq(125, 145, 5),
      y_breaks = seq(30, 45, 5),
      x_labels = paste0(seq(125, 145, 5), "E"),
      y_labels = paste0(seq(30, 45, 5), "N")
    ),
    "ggplot"
  )
  expect_error(
    plot_jpmap("prefectures", data_year = 2021, xlim = c(140, 130)),
    "`xlim` must be NULL or an increasing numeric vector of length 2",
    fixed = TRUE
  )
  expect_error(
    plot_jpmap("prefectures", data_year = 2021, ylim = c(30, NA)),
    "`ylim` must be NULL or an increasing numeric vector of length 2",
    fixed = TRUE
  )
  expect_error(
    plot_jpmap("prefectures", data_year = 2021, inset_boxes = NA),
    "`inset_boxes` must be TRUE or FALSE",
    fixed = TRUE
  )
})
