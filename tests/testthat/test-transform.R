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

test_that("bundled prefecture data are available by default", {
  available <- available_jpmap_data()
  expect_true(any(available$year == 2021))

  map <- jp_map("prefectures", data_year = 2021)
  expect_s3_class(map, "sf")
  expect_equal(nrow(map), 47)
})

test_that("bundled Okinawa municipalities are available by default", {
  map <- jp_map("municipalities", include = "Okinawa", data_year = 2021, inset = FALSE)

  expect_s3_class(map, "sf")
  expect_equal(nrow(map), 41)
  expect_true(all(map$prefecture == "Okinawa"))
  expect_false(any(is.na(map$municipality)))
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
  boxes <- jpmap_inset_boxes(c("okinawa", "ogasawara"))
  plot <- plot_jpmap("prefectures", data_year = 2021, inset_boxes = FALSE)

  expect_s3_class(boxes, "sf")
  expect_equal(nrow(boxes), 2)
  expect_true(all(boxes$region %in% c("okinawa", "ogasawara")))
  expect_s3_class(plot, "ggplot")
  expect_error(
    plot_jpmap("prefectures", data_year = 2021, inset_boxes = NA),
    "`inset_boxes` must be TRUE or FALSE",
    fixed = TRUE
  )
})
