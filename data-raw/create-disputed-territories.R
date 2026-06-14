library(sf)

dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)

natural_earth_zip <- "/private/tmp/ne_10m_land.zip"
natural_earth_url <- "https://naturalearth.s3.amazonaws.com/10m_physical/ne_10m_land.zip"
if (!file.exists(natural_earth_zip)) {
  utils::download.file(natural_earth_url, natural_earth_zip, mode = "wb")
}

natural_earth_dir <- "/private/tmp/ne_10m_land"
dir.create(natural_earth_dir, showWarnings = FALSE)
utils::unzip(natural_earth_zip, exdir = natural_earth_dir)

natural_earth_land <- sf::st_read(
  file.path(natural_earth_dir, "ne_10m_land.shp"),
  quiet = TRUE
)
natural_earth_land <- sf::st_transform(natural_earth_land, 4326)
land_parts <- sf::st_sf(
  geometry = sf::st_cast(sf::st_geometry(natural_earth_land), "POLYGON", warn = FALSE),
  crs = 4326
)
land_centroids <- sf::st_coordinates(sf::st_centroid(land_parts))
land_parts$lon <- land_centroids[, "X"]
land_parts$lat <- land_centroids[, "Y"]

sf::sf_use_s2(FALSE)

natural_earth_shapes <- list(
  northern_territories = land_parts[
    land_parts$lon >= 145.25 & land_parts$lon <= 148.9 &
      land_parts$lat >= 43.35 & land_parts$lat <= 45.55,
  ],
  senkaku = land_parts[
    land_parts$lon >= 123.45 & land_parts$lon <= 124.65 &
      land_parts$lat >= 25.70 & land_parts$lat <= 26.00,
  ]
)

overpass_way_polygons <- function(json_path, way_ids = NULL, natural = NULL) {
  `%||%` <- function(x, y) if (is.null(x)) y else x
  data <- jsonlite::fromJSON(json_path, simplifyVector = FALSE)
  geometries <- list()
  for (element in data$elements) {
    if (!identical(element$type, "way") || is.null(element$geometry)) {
      next
    }
    if (!is.null(way_ids) && !element$id %in% way_ids) {
      next
    }
    natural_value <- element$tags$natural %||% NA_character_
    if (!is.null(natural) && (is.na(natural_value) || !natural_value %in% natural)) {
      next
    }
    coords <- do.call(
      rbind,
      lapply(element$geometry, function(point) c(point$lon, point$lat))
    )
    coords <- coords[c(TRUE, rowSums(abs(diff(coords))) > 0), , drop = FALSE]
    if (nrow(coords) < 4) {
      next
    }
    if (!all(coords[1, ] == coords[nrow(coords), ])) {
      coords <- rbind(coords, coords[1, ])
    }
    geometries[[length(geometries) + 1]] <- sf::st_polygon(list(coords))
  }
  sf::st_sf(geometry = sf::st_sfc(geometries, crs = 4326))
}

download_overpass <- function(query, path) {
  if (file.exists(path)) {
    return(invisible(path))
  }
  url <- paste0(
    "https://overpass-api.de/api/interpreter?data=",
    utils::URLencode(query, reserved = TRUE)
  )
  utils::download.file(url, path, mode = "wb")
  invisible(path)
}

okinotorishima_json <- "/private/tmp/okinotorishima-overpass.json"
download_overpass(
  "[out:json][timeout:25];(way(20.35,136.00,20.50,136.15);relation(20.35,136.00,20.50,136.15););out tags geom;",
  okinotorishima_json
)
okinotorishima <- overpass_way_polygons(
  okinotorishima_json,
  way_ids = c(502661936, 130971315, 502661937)
)

takeshima_json <- "/private/tmp/takeshima-overpass.json"
download_overpass(
  "[out:json][timeout:25];(way(37.20,131.80,37.27,131.90);relation(37.20,131.80,37.27,131.90););out tags geom;",
  takeshima_json
)
takeshima <- overpass_way_polygons(
  takeshima_json,
  natural = c("coastline", "bare_rock", "rock")
)

territory_geometry <- function(x) {
  geometry <- sf::st_make_valid(sf::st_union(sf::st_geometry(x)))
  if (inherits(geometry, "sfc")) {
    return(geometry[[1]])
  }
  geometry
}

source_ne <- "Natural Earth 1:10m land polygons"
source_osm <- "OpenStreetMap geometry via Overpass API"
source_ne_url <- "https://www.naturalearthdata.com/downloads/10m-physical-vectors/10m-land/"
source_osm_url <- "https://www.openstreetmap.org/copyright"
note <- paste(
  "Cartographic island/reef geometry for an opt-in disputed territory or",
  "disputed maritime/EEZ-status area; not an official boundary."
)

territories <- sf::st_sf(
  data.frame(
    dispute_region = c("northern_territories", "okinotorishima", "senkaku", "takeshima"),
    name_en = c(
      "Northern Territories",
      "Okinotorishima",
      "Senkaku Islands",
      "Takeshima / Liancourt Rocks"
    ),
    name_ja = c(
      "\u5317\u65b9\u9818\u571f",
      "\u6c96\u30ce\u9ce5\u5cf6",
      "\u5c16\u95a3\u8af8\u5cf6",
      "\u7af9\u5cf6"
    ),
    source = c(source_ne, source_osm, source_ne, source_osm),
    source_url = c(source_ne_url, source_osm_url, source_ne_url, source_osm_url),
    note = note,
    stringsAsFactors = FALSE
  ),
  geometry = sf::st_sfc(
    territory_geometry(natural_earth_shapes$northern_territories),
    territory_geometry(okinotorishima),
    territory_geometry(natural_earth_shapes$senkaku),
    territory_geometry(takeshima),
    crs = 4326
  )
)

gpkg <- file.path("inst/extdata", "jpmap_disputed_territories.gpkg")
if (file.exists(gpkg)) {
  unlink(gpkg)
}
sf::st_write(territories, gpkg, layer = "territorial_disputes", quiet = TRUE)
