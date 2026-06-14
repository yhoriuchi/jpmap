#' Draw an interactive Japan map with leaflet
#'
#' `jp_map_leaflet()` creates a simple interactive web map from `jpmap`
#' boundaries. It uses literal longitude/latitude geography because Leaflet
#' web tiles expect WGS84 coordinates. Use [plot_jpmap()] when you want the
#' static Okinawa and Ogasawara inset layout.
#'
#' @inheritParams jp_map
#' @param data Optional data frame to join to the map before drawing.
#' @param values Optional column to use for polygon fill colors.
#' @param by Optional join column passed to [jp_map_join()].
#' @param palette Palette name or color vector passed to Leaflet palette
#'   functions when `values` is supplied.
#' @param fill Polygon fill color used when `values` is `NULL`.
#' @param color Polygon outline color.
#' @param weight Polygon outline weight.
#' @param opacity Polygon outline opacity.
#' @param fill_opacity Polygon fill opacity.
#' @param na_color Fill color for missing `values`.
#' @param label `NULL` for default region labels, `FALSE` for no labels, a
#'   column name, or a character vector with one value per map row.
#' @param popup `NULL` for default popups, `FALSE` for no popups, a column name,
#'   or a character vector with one value per map row.
#' @param tiles Whether to add default OpenStreetMap tiles.
#' @param legend Whether to add a legend when `values` is supplied.
#' @param fit_bounds Whether to zoom the widget to the map bounds.
#' @param disputed_fill Fill color for opt-in disputed-territory shapes.
#' @param disputed_color Outline color for opt-in disputed-territory shapes.
#' @param disputed_dots Whether to draw circle markers on opt-in
#'   disputed-territory shapes.
#' @param disputed_dot_radius Radius for disputed-territory circle markers.
#' @param ... Additional arguments passed to [leaflet::leaflet()].
#'
#' @return A `leaflet` htmlwidget.
#' @export
#'
#' @examples
#' if (requireNamespace("leaflet", quietly = TRUE)) {
#'   data("jp_prefecture_gdp")
#'   jp_map_leaflet(
#'     "prefecture",
#'     data = jp_prefecture_gdp,
#'     values = "gdp_per_capita_jpy"
#'   )
#' }
jp_map_leaflet <- function(regions = c("prefectures", "prefecture", "municipalities", "municipality"),
                           include = c(),
                           exclude = c(),
                           data = data.frame(),
                           values = NULL,
                           by = NULL,
                           data_year = NULL,
                           territorial_disputes = FALSE,
                           data_dir = NULL,
                           palette = "YlOrRd",
                           fill = "grey92",
                           color = "grey35",
                           weight = 1,
                           opacity = 1,
                           fill_opacity = 0.75,
                           na_color = "#D9D9D9",
                           label = NULL,
                           popup = NULL,
                           tiles = TRUE,
                           legend = TRUE,
                           fit_bounds = TRUE,
                           disputed_fill = "#F6C85F",
                           disputed_color = "#2C2A29",
                           disputed_dots = TRUE,
                           disputed_dot_radius = 5,
                           ...) {
  if (!requireNamespace("leaflet", quietly = TRUE)) {
    stop("`jp_map_leaflet()` requires the leaflet package. Install it with `install.packages(\"leaflet\")`.", call. = FALSE)
  }

  layer <- canonical_region(regions)
  map <- jp_map(
    regions = layer,
    include = include,
    exclude = exclude,
    data_year = data_year,
    inset = FALSE,
    territorial_disputes = territorial_disputes,
    data_dir = data_dir
  )
  map <- sf::st_transform(map, 4326)

  if (nrow(data) > 0) {
    map <- jp_map_join(map, data, by = by, values = values)
  }
  if (!is.null(values) && !values %in% names(map)) {
    stop("`values` column not found: ", values, call. = FALSE)
  }

  styles <- leaflet_polygon_styles(
    map,
    values = values,
    palette = palette,
    fill = fill,
    color = color,
    na_color = na_color,
    disputed_fill = disputed_fill,
    disputed_color = disputed_color
  )
  labels <- leaflet_text(map, label, default = leaflet_default_labels(map, values))
  popups <- leaflet_text(map, popup, default = leaflet_default_popups(map, values, labels))

  widget <- leaflet::leaflet(data = map, ...)
  if (isTRUE(tiles)) {
    widget <- leaflet::addTiles(widget)
  }
  widget <- leaflet::addPolygons(
    widget,
    fillColor = styles$fill,
    color = styles$color,
    weight = weight,
    opacity = opacity,
    fillOpacity = fill_opacity,
    label = labels,
    popup = popups
  )

  if (!is.null(values) && isTRUE(legend)) {
    widget <- leaflet::addLegend(
      widget,
      pal = styles$palette,
      values = map[[values]],
      title = values,
      opacity = fill_opacity
    )
  }

  disputed <- leaflet_disputed_features(map)
  if (nrow(disputed) > 0 && isTRUE(disputed_dots)) {
    dots <- disputed_dot_points(disputed)
    coords <- sf::st_coordinates(dots)
    dot_labels <- leaflet_text(dots, label, default = leaflet_default_labels(dots, values = NULL))
    widget <- leaflet::addCircleMarkers(
      widget,
      lng = coords[, "X"],
      lat = coords[, "Y"],
      radius = disputed_dot_radius,
      fillColor = disputed_color,
      color = "white",
      weight = 1,
      fillOpacity = 1,
      label = dot_labels
    )
  }

  if (isTRUE(fit_bounds) && nrow(map) > 0) {
    bbox <- sf::st_bbox(map)
    widget <- leaflet::fitBounds(
      widget,
      lng1 = unname(bbox[["xmin"]]),
      lat1 = unname(bbox[["ymin"]]),
      lng2 = unname(bbox[["xmax"]]),
      lat2 = unname(bbox[["ymax"]])
    )
  }

  widget
}

leaflet_polygon_styles <- function(map,
                                   values = NULL,
                                   palette = "YlOrRd",
                                   fill = "grey92",
                                   color = "grey35",
                                   na_color = "#D9D9D9",
                                   disputed_fill = "#F6C85F",
                                   disputed_color = "#2C2A29") {
  disputed <- leaflet_disputed_index(map)

  if (is.null(values)) {
    fill_colors <- rep(fill, nrow(map))
    palette_fun <- NULL
  } else {
    value <- map[[values]]
    palette_fun <- if (is.numeric(value)) {
      leaflet::colorNumeric(palette, domain = value, na.color = na_color)
    } else {
      leaflet::colorFactor(palette, domain = value, na.color = na_color)
    }
    fill_colors <- palette_fun(value)
  }

  line_colors <- rep(color, nrow(map))
  if (any(disputed)) {
    fill_colors[disputed] <- disputed_fill
    line_colors[disputed] <- disputed_color
  }

  list(fill = fill_colors, color = line_colors, palette = palette_fun)
}

leaflet_text <- function(map, value, default) {
  if (isFALSE(value)) {
    return(NULL)
  }
  if (is.null(value) || isTRUE(value)) {
    return(default)
  }
  if (is.character(value) && length(value) == 1 && value %in% names(map)) {
    return(as.character(map[[value]]))
  }
  if (length(value) == nrow(map)) {
    return(as.character(value))
  }
  stop("`label` and `popup` must be NULL, FALSE, a column name, or a vector with one value per map row.", call. = FALSE)
}

leaflet_default_labels <- function(map, values = NULL) {
  col <- leaflet_default_label_column(map)
  labels <- as.character(map[[col]])
  if (!is.null(values) && values %in% names(map)) {
    labels <- ifelse(
      is.na(map[[values]]),
      labels,
      paste0(labels, ": ", map[[values]])
    )
  }
  labels
}

leaflet_default_popups <- function(map, values = NULL, labels = NULL) {
  labels %||% leaflet_default_labels(map, values)
}

leaflet_default_label_column <- function(map) {
  candidates <- c(
    "municipality",
    "municipality_ja",
    "municipality_full_ja",
    "prefecture",
    "prefecture_ja",
    "territory",
    "territory_ja"
  )
  hit <- candidates[candidates %in% names(map)]
  if (length(hit) == 0) {
    stop("No label column is available for this map.", call. = FALSE)
  }
  hit[[1]]
}

leaflet_disputed_index <- function(map) {
  "is_disputed_territory" %in% names(map) & map$is_disputed_territory %in% TRUE
}

leaflet_disputed_features <- function(map) {
  disputed <- leaflet_disputed_index(map)
  map[disputed, , drop = FALSE]
}
