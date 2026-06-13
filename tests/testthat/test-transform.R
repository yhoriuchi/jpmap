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
