jpmap_crs <- function() {
  sf::st_crs(jpmap_crs_proj4())
}

jpmap_crs_proj4 <- function() {
  paste(
    "+proj=laea",
    "+lat_0=37.5",
    "+lon_0=137.5",
    "+x_0=0",
    "+y_0=0",
    "+datum=WGS84",
    "+units=m",
    "+no_defs"
  )
}
