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

  if (!is.null(values)) {
    if (!values %in% names(map)) {
      stop("`values` column not found: ", values, call. = FALSE)
    }
    fill_mapping <- ggplot2::aes(fill = !!rlang::sym(values))
    plot <- ggplot2::ggplot(map) +
      ggplot2::geom_sf(fill_mapping, color = color, linewidth = linewidth, ...)
  } else {
    plot <- ggplot2::ggplot(map) +
      ggplot2::geom_sf(fill = fill, color = color, linewidth = linewidth, ...)
  }

  inset_regions <- normalize_inset(inset, okinawa = okinawa, ogasawara = ogasawara)
  if (length(inset_regions) > 0 && isTRUE(inset_boxes)) {
    boxes <- jpmap_inset_boxes(inset_regions)
    plot <- plot +
      ggplot2::geom_sf(
        data = boxes,
        fill = NA,
        color = inset_box_color,
        linewidth = inset_box_linewidth,
        inherit.aes = FALSE
      )
  }

  if (length(inset_regions) > 0) {
    limits <- jpmap_default_plot_limits()
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

jpmap_default_plot_limits <- function() {
  n <- 25L
  frame <- data.frame(
    lon = c(
      seq(128, 150, length.out = n),
      rep(150, n),
      seq(150, 128, length.out = n),
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
  list(xlim = range(frame$x), ylim = range(frame$y))
}

jpmap_inset_boxes <- function(inset_regions) {
  boxes <- lapply(inset_regions, function(region) {
    bbox <- inset_target_bbox(region)
    sf::st_sf(region = region, geometry = projected_inset_box(bbox))
  })

  do.call(rbind, boxes)
}

projected_inset_box <- function(bbox) {
  corners <- matrix(
    c(
      bbox$xlim[1], bbox$ylim[1],
      bbox$xlim[2], bbox$ylim[1],
      bbox$xlim[2], bbox$ylim[2],
      bbox$xlim[1], bbox$ylim[2]
    ),
    ncol = 2,
    byrow = TRUE
  )
  corners <- sf::st_sfc(sf::st_multipoint(corners), crs = 4326)
  corners <- sf::st_coordinates(sf::st_transform(corners, jpmap_crs()))
  xlim <- range(corners[, "X"])
  ylim <- range(corners[, "Y"])

  ring <- matrix(
    c(
      xlim[1], ylim[1],
      xlim[2], ylim[1],
      xlim[2], ylim[2],
      xlim[1], ylim[2],
      xlim[1], ylim[1]
    ),
    ncol = 2,
    byrow = TRUE
  )
  sf::st_sfc(sf::st_polygon(list(ring)), crs = jpmap_crs())
}

inset_target_bbox <- function(region) {
  switch(
    region,
    okinawa = list(xlim = c(128.0, 137.8), ylim = c(39.4, 45.5)),
    ogasawara = list(xlim = c(142.2, 147.3), ylim = c(30.0, 37.1)),
    stop("Unknown inset region: ", region, call. = FALSE)
  )
}
