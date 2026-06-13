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
                       data_dir = NULL,
                       color = "white",
                       linewidth = 0.2,
                       ...) {
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
      ggplot2::geom_sf(color = color, linewidth = linewidth, ...)
  }

  inset_regions <- normalize_inset(inset, okinawa = okinawa, ogasawara = ogasawara)
  if (length(inset_regions) > 0) {
    limits <- jpmap_default_plot_limits()
    plot <- plot +
      ggplot2::coord_sf(
        crs = jpmap_crs(),
        xlim = limits$xlim,
        ylim = limits$ylim,
        datum = NA
      )
  } else {
    plot <- plot +
      ggplot2::coord_sf(crs = jpmap_crs(), datum = NA)
  }

  plot <- plot + ggplot2::theme_void()

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
