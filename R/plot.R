plot_jpmap <- function(regions = c("prefectures", "prefecture", "municipalities", "municipality"),
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
                       territorial_disputes = TRUE,
                       disputed_fill = NULL,
                       disputed_color = NULL,
                       disputed_linewidth = NULL,
                       disputed_dots = FALSE,
                       disputed_dot_fill = "#001040",
                       disputed_dot_color = "white",
                       disputed_dot_size = 1.25,
                       disputed_dot_stroke = 0.2,
                       inset_boxes = TRUE,
                       inset_box_color = "grey50",
                       inset_box_linewidth = 0.35,
                       data_dir = NULL,
                       xlim = NULL,
                       ylim = NULL,
                       x_breaks = ggplot2::waiver(),
                       y_breaks = ggplot2::waiver(),
                       x_labels = ggplot2::waiver(),
                       y_labels = ggplot2::waiver(),
                       fill = "grey92",
                       color = "grey35",
                       linewidth = 0.25,
                       ...) {
  check_inset_switch(inset_boxes, "inset_boxes")
  check_inset_switch(disputed_dots, "disputed_dots")
  check_axis_limits(xlim, "xlim")
  check_axis_limits(ylim, "ylim")
  disputed_regions <- normalize_territorial_disputes(territorial_disputes)

  layer <- canonical_region(regions)
  map <- jp_map(
    regions = layer,
    include = include,
    exclude = exclude,
    data_year = data_year,
    inset = inset,
    okinawa = okinawa,
    ogasawara = ogasawara,
    territorial_disputes = disputed_regions,
    data_dir = data_dir
  )

  if (nrow(data) > 0) {
    map <- jp_map_with_data(map, data, values = values)
  }

  inset_regions <- normalize_inset(inset, okinawa = okinawa, ogasawara = ogasawara)
  plot <- ggplot2::ggplot()

  if (length(inset_regions) > 0 && isTRUE(inset_boxes)) {
    boxes <- jpmap_inset_boxes(inset_regions, territorial_disputes = disputed_regions)
    plot <- plot +
      ggplot2::geom_sf(
        data = boxes,
        fill = "grey92",
        color = NA,
        inherit.aes = FALSE
      )

    graticules <- jpmap_inset_graticules(inset_regions, territorial_disputes = disputed_regions)
    plot <- plot +
      ggplot2::geom_sf(
        data = graticules$lines,
        color = "white",
        linewidth = 0.35,
        inherit.aes = FALSE
      )
  }

  if (!is.null(values)) {
    if (!values %in% names(map)) {
      stop("`values` column not found: ", values, call. = FALSE)
    }
    fill_mapping <- ggplot2::aes(fill = !!rlang::sym(values))
    plot <- plot +
      ggplot2::geom_sf(data = map, fill_mapping, color = color, linewidth = linewidth, ...)
  } else {
    plot <- plot +
      ggplot2::geom_sf(data = map, fill = fill, color = color, linewidth = linewidth, ...)
  }

  disputed_map <- disputed_plot_features(map)
  if (nrow(disputed_map) > 0) {
    plot <- plot +
      ggplot2::geom_sf(
        data = disputed_map,
        fill = disputed_fill %||% fill,
        color = disputed_color %||% color,
        linewidth = disputed_linewidth %||% linewidth,
        inherit.aes = FALSE
      )

    if (isTRUE(disputed_dots)) {
      plot <- plot +
        ggplot2::geom_sf(
          data = disputed_dot_points(disputed_map),
          shape = 21,
          fill = disputed_dot_fill,
          color = disputed_dot_color,
          size = disputed_dot_size,
          stroke = disputed_dot_stroke,
          inherit.aes = FALSE
        )
    }
  }

  if (length(inset_regions) > 0 && isTRUE(inset_boxes)) {
    plot <- plot +
      ggplot2::geom_sf_text(
        data = graticules$labels,
        ggplot2::aes(label = .data$label, hjust = .data$hjust, vjust = .data$vjust),
        color = "grey35",
        size = 2.3,
        inherit.aes = FALSE
      ) +
      ggplot2::geom_sf(
        data = boxes,
        fill = NA,
        color = inset_box_color,
        linewidth = inset_box_linewidth,
        inherit.aes = FALSE
      )
  }

  axis_controls <- any(!vapply(
    list(x_breaks, y_breaks, x_labels, y_labels),
    ggplot2::is_waiver,
    logical(1)
  ))
  limits <- jpmap_plot_limits(
    inset_regions,
    map = map,
    xlim = xlim,
    ylim = ylim,
    lonlat = axis_controls,
    territorial_disputes = disputed_regions
  )
  plot <- plot +
    ggplot2::coord_sf(
      crs = jpmap_crs(),
      xlim = limits$xlim,
      ylim = limits$ylim,
      expand = FALSE,
      default_crs = limits$default_crs,
      datum = sf::st_crs(4326),
      lims_method = "box"
    ) +
    ggplot2::scale_x_continuous(breaks = x_breaks, labels = x_labels) +
    ggplot2::scale_y_continuous(breaks = y_breaks, labels = y_labels)

  plot <- plot +
    ggplot2::theme_gray() +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )

  if (isTRUE(labels)) {
    label_col <- label_column(layer, map)
    label_points <- suppressWarnings(sf::st_point_on_surface(map))
    plot <- plot +
      ggplot2::geom_sf_text(
        data = label_points,
        ggplot2::aes(label = !!rlang::sym(label_col)),
        color = label_color,
        size = if (identical(layer, "municipalities")) 1.6 else 2.6
      )
  }

  plot
}

disputed_plot_features <- function(map) {
  if (!"is_disputed_territory" %in% names(map)) {
    return(map[FALSE, , drop = FALSE])
  }
  map[map$is_disputed_territory %in% TRUE, , drop = FALSE]
}

disputed_dot_points <- function(disputed_map) {
  if (nrow(disputed_map) == 0) {
    return(sf::st_sf(geometry = sf::st_sfc(crs = sf::st_crs(disputed_map))))
  }

  parts <- suppressWarnings(sf::st_cast(disputed_map, "POLYGON"))
  parts <- parts[!sf::st_is_empty(parts), , drop = FALSE]
  suppressWarnings(sf::st_point_on_surface(parts))
}

check_axis_limits <- function(limits, name) {
  if (is.null(limits)) {
    return(invisible(NULL))
  }
  if (!is.numeric(limits) || length(limits) != 2 || anyNA(limits) || limits[1] >= limits[2]) {
    stop("`", name, "` must be NULL or an increasing numeric vector of length 2.", call. = FALSE)
  }
  invisible(NULL)
}

label_column <- function(regions, map) {
  candidates <- if (identical(regions, "municipalities")) {
    c("municipality", "municipality_ja", "municipality_full_ja")
  } else {
    c("prefecture", "prefecture_ja")
  }
  hit <- candidates[candidates %in% names(map)]
  if (length(hit) == 0) {
    stop("No label column is available for this map.", call. = FALSE)
  }
  hit[[1]]
}

jpmap_plot_limits <- function(inset_regions,
                              map = NULL,
                              xlim = NULL,
                              ylim = NULL,
                              lonlat = FALSE,
                              territorial_disputes = FALSE) {
  user_limits <- !is.null(xlim) || !is.null(ylim) || isTRUE(lonlat)
  defaults <- if (length(inset_regions) > 0) {
    if (isTRUE(user_limits)) {
      jpmap_default_plot_limits(inset_regions, map, territorial_disputes = territorial_disputes)
    } else {
      jpmap_default_projected_plot_limits(inset_regions, map, territorial_disputes = territorial_disputes)
    }
  } else {
    list(xlim = NULL, ylim = NULL, default_crs = sf::st_crs(4326))
  }

  list(
    xlim = xlim %||% defaults$xlim,
    ylim = ylim %||% defaults$ylim,
    default_crs = defaults$default_crs
  )
}

jpmap_default_plot_limits <- function(inset_regions = c("okinawa", "ogasawara"),
                                      map = NULL,
                                      territorial_disputes = FALSE) {
  if (is.null(map)) {
    xlim <- c(128, 148)
    ylim <- c(30, 46)
  } else {
    map_bbox <- sf::st_bbox(sf::st_transform(map, 4326))
    xlim <- c(map_bbox[["xmin"]], map_bbox[["xmax"]])
    ylim <- c(map_bbox[["ymin"]], map_bbox[["ymax"]])
  }

  if (length(inset_regions) > 0) {
    boxes <- sf::st_bbox(sf::st_transform(
      jpmap_inset_boxes(inset_regions, territorial_disputes = territorial_disputes),
      4326
    ))
    xlim <- range(xlim, boxes[["xmin"]], boxes[["xmax"]])
    ylim <- range(ylim, boxes[["ymin"]], boxes[["ymax"]])
  }

  x_padding <- 0.08
  y_padding <- 0.08
  list(
    xlim = xlim + c(-x_padding, x_padding),
    ylim = ylim + c(-y_padding, y_padding),
    default_crs = sf::st_crs(4326)
  )
}

jpmap_default_projected_plot_limits <- function(inset_regions = c("okinawa", "ogasawara"),
                                                map = NULL,
                                                territorial_disputes = FALSE) {
  geometries <- if (is.null(map)) {
    sf::st_sfc(crs = jpmap_crs())
  } else {
    sf::st_geometry(map)
  }

  if (length(inset_regions) > 0) {
    geometries <- c(
      geometries,
      sf::st_geometry(jpmap_inset_boxes(inset_regions, territorial_disputes = territorial_disputes))
    )
  }

  bbox <- sf::st_bbox(geometries)
  x_padding <- 12000
  y_padding <- 12000
  list(
    xlim = c(bbox[["xmin"]] - x_padding, bbox[["xmax"]] + x_padding),
    ylim = c(bbox[["ymin"]] - y_padding, bbox[["ymax"]] + y_padding),
    default_crs = NULL
  )
}

jpmap_inset_boxes <- function(inset_regions, territorial_disputes = FALSE) {
  boxes <- lapply(inset_regions, function(region) {
    bbox <- inset_projected_bbox(region, territorial_disputes = territorial_disputes)
    sf::st_sf(region = region, geometry = projected_inset_box(bbox))
  })

  do.call(rbind, boxes)
}

projected_inset_box <- function(bbox) {
  ring <- matrix(
    c(
      bbox$xlim[1], bbox$ylim[1],
      bbox$xlim[2], bbox$ylim[1],
      bbox$xlim[2], bbox$ylim[2],
      bbox$xlim[1], bbox$ylim[2],
      bbox$xlim[1], bbox$ylim[1]
    ),
    ncol = 2,
    byrow = TRUE
  )
  sf::st_sfc(sf::st_polygon(list(ring)), crs = jpmap_crs())
}

inset_projected_bbox <- function(region, territorial_disputes = FALSE) {
  spec <- inset_box_source_spec(region, territorial_disputes = territorial_disputes)
  transformed <- transform_source_bbox(region, spec)
  bbox <- sf::st_bbox(transformed)
  x_padding <- spec$x_padding %||% 30000
  y_padding <- spec$y_padding %||% 30000
  list(
    xlim = c(bbox[["xmin"]] - x_padding, bbox[["xmax"]] + x_padding),
    ylim = c(bbox[["ymin"]] - y_padding, bbox[["ymax"]] + y_padding)
  )
}

transform_source_bbox <- function(region, spec) {
  n <- spec$n %||% 80L
  perimeter <- rbind(
    cbind(seq(spec$xlim[1], spec$xlim[2], length.out = n), rep(spec$ylim[1], n)),
    cbind(rep(spec$xlim[2], n), seq(spec$ylim[1], spec$ylim[2], length.out = n)),
    cbind(seq(spec$xlim[2], spec$xlim[1], length.out = n), rep(spec$ylim[2], n)),
    cbind(rep(spec$xlim[1], n), seq(spec$ylim[2], spec$ylim[1], length.out = n))
  )
  geometry <- sf::st_sfc(sf::st_linestring(perimeter), crs = 4326)
  projected <- sf::st_transform(geometry, jpmap_crs())
  transform <- inset_transform_spec(region)
  affine_inset(
    projected,
    source_lonlat = transform$source_lonlat,
    target_lonlat = transform$target_lonlat,
    scale = transform$scale
  )
}

jpmap_inset_graticules <- function(inset_regions, territorial_disputes = FALSE) {
  graticules <- lapply(inset_regions, inset_graticule, territorial_disputes = territorial_disputes)
  list(
    lines = do.call(rbind, lapply(graticules, `[[`, "lines")),
    labels = do.call(rbind, lapply(graticules, `[[`, "labels"))
  )
}

inset_graticule <- function(region, territorial_disputes = FALSE) {
  spec <- inset_graticule_spec(region, territorial_disputes = territorial_disputes)
  line_data <- build_inset_graticule_lines(region, spec)
  lines <- clip_inset_graticule(line_data, region, territorial_disputes = territorial_disputes)
  labels <- build_inset_graticule_labels(lines, region, territorial_disputes = territorial_disputes)
  list(lines = lines, labels = labels)
}

build_inset_graticule_lines <- function(region, spec) {
  lines <- list()
  attrs <- data.frame(
    region = character(),
    type = character(),
    value = numeric(),
    label = character()
  )

  lon_labels <- spec$lon_labels %||% rep(TRUE, length(spec$lons))
  for (j in seq_along(spec$lons)) {
    lon <- spec$lons[[j]]
    line <- matrix(
      c(rep(lon, spec$n), seq(spec$ylim[1], spec$ylim[2], length.out = spec$n)),
      ncol = 2
    )
    lines[[length(lines) + 1]] <- sf::st_linestring(line)
    label <- if (isTRUE(lon_labels[[j]])) degree_label(lon, "E") else NA_character_
    attrs[nrow(attrs) + 1, ] <- list(region, "lon", lon, label)
  }

  lat_labels <- spec$lat_labels %||% rep(TRUE, length(spec$lats))
  for (j in seq_along(spec$lats)) {
    lat <- spec$lats[[j]]
    line <- matrix(
      c(seq(spec$xlim[1], spec$xlim[2], length.out = spec$n), rep(lat, spec$n)),
      ncol = 2
    )
    lines[[length(lines) + 1]] <- sf::st_linestring(line)
    label <- if (isTRUE(lat_labels[[j]])) degree_label(lat, "N") else NA_character_
    attrs[nrow(attrs) + 1, ] <- list(region, "lat", lat, label)
  }

  geometry <- sf::st_sfc(lines, crs = 4326)
  out <- sf::st_sf(attrs, geometry = geometry)
  projected <- sf::st_transform(out, jpmap_crs())
  transform <- inset_transform_spec(region)
  sf::st_geometry(projected) <- affine_inset(
    sf::st_geometry(projected),
    source_lonlat = transform$source_lonlat,
    target_lonlat = transform$target_lonlat,
    scale = transform$scale
  )
  projected
}

clip_inset_graticule <- function(graticule, region, territorial_disputes = FALSE) {
  box <- jpmap_inset_boxes(region, territorial_disputes = territorial_disputes)
  out <- suppressWarnings(sf::st_intersection(graticule, sf::st_geometry(box)))
  out <- out[!sf::st_is_empty(out), ]
  if (nrow(out) == 0) {
    return(out)
  }
  out
}

build_inset_graticule_labels <- function(lines, region, territorial_disputes = FALSE) {
  lines <- lines[!is.na(lines$label), ]
  if (nrow(lines) == 0) {
    return(empty_inset_graticule_labels())
  }

  box <- sf::st_bbox(jpmap_inset_boxes(region, territorial_disputes = territorial_disputes))
  offsets <- inset_label_offsets(region)
  x_offset <- offsets$x * (box[["xmax"]] - box[["xmin"]])
  y_offset <- offsets$y * (box[["ymax"]] - box[["ymin"]])

  labels <- lapply(seq_len(nrow(lines)), function(i) {
    coords <- sf::st_coordinates(lines[i, ])
    if (identical(lines$type[[i]], "lon")) {
      point <- point_on_line_at_axis(coords, "y", box[["ymin"]] + y_offset)
      hjust <- 0.5
      vjust <- 0.5
    } else {
      point <- point_on_line_at_axis(coords, "x", box[["xmin"]] + x_offset)
      hjust <- 0
      vjust <- 0.5
    }
    data.frame(
      region = lines$region[[i]],
      type = lines$type[[i]],
      value = lines$value[[i]],
      label = lines$label[[i]],
      x = point[[1]],
      y = point[[2]],
      hjust = hjust,
      vjust = vjust
    )
  })

  labels <- do.call(rbind, labels)
  geometry <- sf::st_sfc(
    lapply(seq_len(nrow(labels)), function(i) sf::st_point(c(labels$x[[i]], labels$y[[i]]))),
    crs = jpmap_crs()
  )
  sf::st_sf(labels, geometry = geometry)
}

inset_label_offsets <- function(region) {
  switch(
    region,
    okinawa = list(x = 0.18, y = 0.025),
    ogasawara = list(x = 0.13, y = 0.025),
    list(x = 0.075, y = 0.055)
  )
}

empty_inset_graticule_labels <- function() {
  sf::st_sf(
    region = character(),
    type = character(),
    value = numeric(),
    label = character(),
    x = numeric(),
    y = numeric(),
    hjust = numeric(),
    vjust = numeric(),
    geometry = sf::st_sfc(crs = jpmap_crs())
  )
}

point_on_line_at_axis <- function(coords, axis = c("x", "y"), value) {
  axis <- match.arg(axis)
  axis_col <- if (identical(axis, "x")) "X" else "Y"
  other_col <- if (identical(axis, "x")) "Y" else "X"

  coords <- coords[is.finite(coords[, "X"]) & is.finite(coords[, "Y"]), c("X", "Y"), drop = FALSE]
  if (nrow(coords) == 0) {
    return(c(NA_real_, NA_real_))
  }
  if (nrow(coords) < 2) {
    point <- coords[1, ]
    return(c(point[["X"]], point[["Y"]]))
  }

  from <- coords[-nrow(coords), axis_col]
  to <- coords[-1, axis_col]
  crosses <- which(
    is.finite(from) & is.finite(to) &
      value >= pmin(from, to) &
      value <= pmax(from, to) &
      from != to
  )

  if (length(crosses) > 0) {
    i <- crosses[[1]]
    fraction <- (value - from[[i]]) / (to[[i]] - from[[i]])
    other <- coords[i, other_col] + fraction * (coords[i + 1, other_col] - coords[i, other_col])
    if (identical(axis, "x")) {
      return(c(value, other))
    }
    return(c(other, value))
  }

  closest <- which.min(abs(coords[, axis_col] - value))
  c(coords[closest, "X"], coords[closest, "Y"])
}

inset_graticule_spec <- function(region, territorial_disputes = FALSE) {
  disputed_regions <- normalize_territorial_disputes(territorial_disputes)
  switch(
    region,
    okinawa = list(
      xlim = c(122.6, 132.2),
      ylim = c(24.0, 28.9),
      lons = c(124, 128, 132),
      lon_labels = c(FALSE, TRUE, TRUE),
      lats = c(24, 26, 28),
      n = 100L
    ),
    ogasawara = list(
      xlim = c(141, 154.5),
      ylim = if ("okinotorishima" %in% disputed_regions) c(20.0, 28.2) else c(24.0, 28.2),
      lons = c(142, 146, 150, 154),
      lats = if ("okinotorishima" %in% disputed_regions) c(22, 24, 26, 28) else c(26, 28),
      n = 100L
    ),
    stop("Unknown inset region: ", region, call. = FALSE)
  )
}

degree_label <- function(value, direction) {
  paste0(value, "\u00b0", direction)
}

inset_box_source_spec <- function(region, territorial_disputes = FALSE) {
  disputed_regions <- normalize_territorial_disputes(territorial_disputes)
  switch(
    region,
    okinawa = list(
      xlim = c(122.6, 132.2),
      ylim = c(24.0, 28.9),
      x_padding = 45000,
      y_padding = 35000
    ),
    ogasawara = list(
      xlim = c(141.0, 154.5),
      ylim = if ("okinotorishima" %in% disputed_regions) c(20.0, 28.2) else c(24.0, 28.2),
      x_padding = 45000,
      y_padding = 55000
    ),
    stop("Unknown inset region: ", region, call. = FALSE)
  )
}
