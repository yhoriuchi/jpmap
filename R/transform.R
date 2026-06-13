jpmap_transform <- function(data,
                            input_names = c("lon", "lat"),
                            output_names = input_names,
                            inset = TRUE) {
  if (inherits(data, "sf")) {
    return(transform_sf(data, inset = inset))
  }

  if (inherits(data, "sfc")) {
    return(sf::st_geometry(transform_sf(sf::st_sf(geometry = data), inset = inset)))
  }

  if (is.data.frame(data)) {
    return(transform_data_frame(data, input_names, output_names, inset = inset))
  }

  stop("`data` must be an sf object, sfc geometry vector, or data frame.", call. = FALSE)
}

transform_data_frame <- function(data, input_names, output_names, inset) {
  check_coordinate_names(data, input_names, output_names)

  coords <- data[input_names]
  complete <- stats::complete.cases(coords)
  out <- data
  out[[output_names[1]]] <- NA_real_
  out[[output_names[2]]] <- NA_real_

  if (!any(complete)) {
    return(out)
  }

  pts <- sf::st_as_sf(
    data[complete, , drop = FALSE],
    coords = input_names,
    crs = 4326,
    remove = FALSE
  )
  pts <- transform_sf(pts, inset = inset)
  xy <- sf::st_coordinates(pts)

  out[[output_names[1]]][complete] <- xy[, "X"]
  out[[output_names[2]]][complete] <- xy[, "Y"]
  out
}

transform_sf <- function(data, inset) {
  original <- data
  geom <- sf::st_geometry(original)

  if (is.na(sf::st_crs(geom))) {
    sf::st_crs(geom) <- 4326
    sf::st_geometry(original) <- geom
  }

  wgs84 <- sf::st_transform(original, 4326)
  regions <- classify_inset_regions(wgs84)
  projected <- sf::st_transform(original, jpmap_crs())

  if (isTRUE(inset)) {
    projected_geom <- apply_inset_transform(
      sf::st_geometry(projected),
      regions
    )
    sf::st_geometry(projected) <- projected_geom
  }

  projected
}

check_coordinate_names <- function(data, input_names, output_names) {
  if (length(input_names) != 2) {
    stop("`input_names` must contain exactly two column names.", call. = FALSE)
  }
  if (length(output_names) != 2) {
    stop("`output_names` must contain exactly two column names.", call. = FALSE)
  }
  missing <- setdiff(input_names, names(data))
  if (length(missing) > 0) {
    stop(
      "Missing coordinate column(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
}

classify_inset_regions <- function(data_wgs84) {
  n <- nrow(data_wgs84)
  out <- rep("main", n)

  attrs <- sf::st_drop_geometry(data_wgs84)
  if (nrow(attrs) > 0) {
    pref_col <- first_present(
      names(attrs),
      c("pref_code", "jis_pref_code", "prefecture_code")
    )
    muni_col <- first_present(
      names(attrs),
      c("municipality_code", "city_code", "jis_code", "code")
    )
    pref_name_col <- first_present(
      names(attrs),
      c("prefecture", "prefecture_ja", "full")
    )
    muni_name_col <- first_present(
      names(attrs),
      c("municipality", "municipality_ja", "municipality_full_ja")
    )

    if (!is.null(pref_col)) {
      out[as.character(attrs[[pref_col]]) %in% c("47", "047")] <- "okinawa"
    }
    if (!is.null(pref_name_col)) {
      pref_names <- normalize_key(attrs[[pref_name_col]])
      out[pref_names %in% c("okinawa", normalize_key("\u6c96\u7e04\u770c"))] <- "okinawa"
    }
    if (!is.null(muni_col)) {
      out[as.character(attrs[[muni_col]]) %in% c("13421", "134210")] <- "ogasawara"
    }
    if (!is.null(muni_name_col)) {
      muni_names <- normalize_key(attrs[[muni_name_col]])
      out[muni_names %in% c("ogasawara", normalize_key("\u5c0f\u7b20\u539f\u6751"))] <- "ogasawara"
    }
  }

  unresolved <- out == "main"
  if (any(unresolved)) {
    pts <- suppressWarnings(sf::st_point_on_surface(sf::st_geometry(data_wgs84[unresolved, ])))
    xy <- sf::st_coordinates(pts)
    lon <- xy[, "X"]
    lat <- xy[, "Y"]

    spatial <- rep("main", length(lon))
    spatial[lon >= 122 & lon <= 132.5 & lat >= 23 & lat <= 29.75] <- "okinawa"
    spatial[lon >= 136 & lon <= 154 & lat >= 20 & lat <= 29.75] <- "ogasawara"
    out[unresolved] <- spatial
  }

  out
}

apply_inset_transform <- function(geometry, regions) {
  out <- geometry

  okinawa <- regions == "okinawa"
  if (any(okinawa)) {
    out[okinawa] <- affine_inset(
      out[okinawa],
      source_lonlat = c(127.75, 26.30),
      target_lonlat = c(130.60, 31.00),
      scale = 1.35
    )
  }

  ogasawara <- regions == "ogasawara"
  if (any(ogasawara)) {
    out[ogasawara] <- affine_inset(
      out[ogasawara],
      source_lonlat = c(142.20, 27.10),
      target_lonlat = c(134.40, 30.00),
      scale = 1.75
    )
  }

  sf::st_crs(out) <- jpmap_crs()
  out
}

affine_inset <- function(geometry, source_lonlat, target_lonlat, scale) {
  source <- project_lonlat(source_lonlat)
  target <- project_lonlat(target_lonlat)

  shifted <- (geometry - source) * scale + target
  sf::st_crs(shifted) <- jpmap_crs()
  shifted
}

project_lonlat <- function(lonlat) {
  point <- sf::st_sfc(sf::st_point(lonlat), crs = 4326)
  xy <- sf::st_coordinates(sf::st_transform(point, jpmap_crs()))
  as.numeric(xy[1, c("X", "Y")])
}

first_present <- function(x, candidates) {
  hit <- candidates[candidates %in% x]
  if (length(hit) == 0) {
    NULL
  } else {
    hit[[1]]
  }
}

normalize_key <- function(x) {
  tolower(gsub("[[:space:]_-]+", "", as.character(x)))
}
