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
                       inset_boxes = TRUE,
                       inset_box_color = "grey50",
                       inset_box_linewidth = 0.35,
                       data_dir = NULL,
                       fill = "grey92",
                       color = "grey35",
                       linewidth = 0.25,
                       ...) {
  check_inset_switch(inset_boxes, "inset_boxes")

  layer <- canonical_region(regions)
  map <- jp_map(
    regions = layer,
    include = include,
    exclude = exclude,
    data_year = data_year,
    inset = inset,
    okinawa = okinawa,
    ogasawara = ogasawara,
    data_dir = data_dir
  )

  if (nrow(data) > 0) {
    map <- jp_map_with_data(map, data, values = values)
  }

  inset_regions <- normalize_inset(inset, okinawa = okinawa, ogasawara = ogasawara)
  plot <- ggplot2::ggplot()

  if (length(inset_regions) > 0 && isTRUE(inset_boxes)) {
    boxes <- jpmap_inset_boxes(inset_regions)
    plot <- plot +
      ggplot2::geom_sf(
        data = boxes,
        fill = "grey92",
        color = NA,
        inherit.aes = FALSE
      )

    graticules <- jpmap_inset_graticules(inset_regions)
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

  if (length(inset_regions) > 0 && isTRUE(inset_boxes)) {
    plot <- plot +
      ggplot2::geom_text(
        data = graticules$labels,
        ggplot2::aes(x = x, y = y, label = label),
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

  if (length(inset_regions) > 0) {
    limits <- jpmap_default_plot_limits(inset_regions)
    plot <- plot +
      ggplot2::coord_sf(
        crs = jpmap_crs(),
        xlim = limits$xlim,
        ylim = limits$ylim,
        datum = sf::st_crs(4326)
      )
  } else {
    plot <- plot +
      ggplot2::coord_sf(crs = jpmap_crs(), datum = sf::st_crs(4326))
  }

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

jpmap_default_plot_limits <- function(inset_regions = c("okinawa", "ogasawara")) {
  n <- 25L
  frame <- data.frame(
    lon = c(
      seq(128, 148, length.out = n),
      rep(148, n),
      seq(148, 128, length.out = n),
      rep(128, n)
    ),
    lat = c(
      rep(30, n),
      seq(30, 46, length.out = n),
      rep(46, n),
      seq(46, 30, length.out = n)
    )
  )
  frame <- jpmap_transform(frame, output_names = c("x", "y"), inset = FALSE)
  boxes <- sf::st_bbox(jpmap_inset_boxes(inset_regions))
  xlim <- range(frame$x, boxes[["xmin"]], boxes[["xmax"]])
  ylim <- range(frame$y, boxes[["ymin"]], boxes[["ymax"]])
  x_padding <- 25000
  y_padding <- 30000
  list(
    xlim = xlim + c(-x_padding, x_padding),
    ylim = ylim + c(-y_padding, y_padding)
  )
}

jpmap_inset_boxes <- function(inset_regions) {
  boxes <- lapply(inset_regions, function(region) {
    bbox <- inset_projected_bbox(region)
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

inset_projected_bbox <- function(region) {
  spec <- inset_box_source_spec(region)
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

jpmap_inset_graticules <- function(inset_regions) {
  graticules <- lapply(inset_regions, inset_graticule)
  list(
    lines = do.call(rbind, lapply(graticules, `[[`, "lines")),
    labels = do.call(rbind, lapply(graticules, `[[`, "labels"))
  )
}

inset_graticule <- function(region) {
  spec <- inset_graticule_spec(region)
  line_data <- build_inset_graticule_lines(region, spec)
  lines <- clip_inset_graticule(line_data, region)
  labels <- build_inset_graticule_labels(lines, region)
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

  for (lon in spec$lons) {
    line <- matrix(
      c(rep(lon, spec$n), seq(spec$ylim[1], spec$ylim[2], length.out = spec$n)),
      ncol = 2
    )
    lines[[length(lines) + 1]] <- sf::st_linestring(line)
    attrs[nrow(attrs) + 1, ] <- list(region, "lon", lon, degree_label(lon, "E"))
  }

  for (lat in spec$lats) {
    line <- matrix(
      c(seq(spec$xlim[1], spec$xlim[2], length.out = spec$n), rep(lat, spec$n)),
      ncol = 2
    )
    lines[[length(lines) + 1]] <- sf::st_linestring(line)
    attrs[nrow(attrs) + 1, ] <- list(region, "lat", lat, degree_label(lat, "N"))
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

clip_inset_graticule <- function(graticule, region) {
  box <- jpmap_inset_boxes(region)
  out <- suppressWarnings(sf::st_intersection(graticule, sf::st_geometry(box)))
  out <- out[!sf::st_is_empty(out), ]
  if (nrow(out) == 0) {
    return(out)
  }
  out
}

build_inset_graticule_labels <- function(lines, region) {
  if (nrow(lines) == 0) {
    return(data.frame(region = character(), label = character(), x = numeric(), y = numeric()))
  }

  box <- sf::st_bbox(jpmap_inset_boxes(region))
  x_offset <- 0.025 * (box[["xmax"]] - box[["xmin"]])
  y_offset <- 0.035 * (box[["ymax"]] - box[["ymin"]])

  labels <- lapply(seq_len(nrow(lines)), function(i) {
    coords <- sf::st_coordinates(lines[i, ])
    if (identical(lines$type[[i]], "lon")) {
      x <- stats::median(coords[, "X"])
      y <- box[["ymin"]] + y_offset
    } else {
      x <- box[["xmin"]] + x_offset
      y <- stats::median(coords[, "Y"])
    }
    data.frame(region = lines$region[[i]], label = lines$label[[i]], x = x, y = y)
  })

  do.call(rbind, labels)
}

inset_graticule_spec <- function(region) {
  switch(
    region,
    okinawa = list(
      xlim = c(122.6, 132.2),
      ylim = c(24.0, 28.9),
      lons = c(124, 128, 132),
      lats = c(24, 26, 28),
      n = 100L
    ),
    ogasawara = list(
      xlim = c(141, 154.5),
      ylim = c(24.0, 28.2),
      lons = c(142, 146, 150, 154),
      lats = c(24, 26, 28),
      n = 100L
    ),
    stop("Unknown inset region: ", region, call. = FALSE)
  )
}

degree_label <- function(value, direction) {
  paste0(value, "\u00b0", direction)
}

inset_box_source_spec <- function(region) {
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
      ylim = c(24.0, 28.2),
      x_padding = 45000,
      y_padding = 35000
    ),
    stop("Unknown inset region: ", region, call. = FALSE)
  )
}
