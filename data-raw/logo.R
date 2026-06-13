library(ggplot2)
library(sf)

pkgload::load_all(".", quiet = TRUE)

garnet <- "#782F40"
gold <- "#CEB888"
cream <- "#FBF7ED"
ink <- "#2C2A29"

dir.create("man/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("pkgdown/favicon", recursive = TRUE, showWarnings = FALSE)
dir.create("docs/reference/figures", recursive = TRUE, showWarnings = FALSE)

hexagon <- function(radius = 0.5, center = c(0.5, 0.5), rotation = pi / 6) {
  angles <- rotation + seq(0, 2 * pi, length.out = 7)[-7]
  data.frame(
    x = center[[1]] + radius * cos(angles),
    y = center[[2]] + radius * sin(angles)
  )
}

sf_coordinates <- function(x) {
  geometry <- suppressWarnings(sf::st_collection_extract(sf::st_geometry(x), "POLYGON"))
  coords <- as.data.frame(sf::st_coordinates(geometry))
  group_cols <- grep("^L[0-9]+$", names(coords), value = TRUE)
  coords$group <- do.call(interaction, c(coords[group_cols], drop = TRUE))
  coords
}

scale_coordinates <- function(coords, xlim, ylim, target_x = c(0.14, 0.86),
                              target_y = c(0.24, 0.83)) {
  scale <- min(diff(target_x) / diff(xlim), diff(target_y) / diff(ylim))
  width <- diff(xlim) * scale
  height <- diff(ylim) * scale
  x0 <- target_x[[1]] + (diff(target_x) - width) / 2
  y0 <- target_y[[1]] + (diff(target_y) - height) / 2

  coords$x <- x0 + (coords$X - xlim[[1]]) * scale
  coords$y <- y0 + (coords$Y - ylim[[1]]) * scale
  coords
}

map_data <- function() {
  map <- jp_map("prefectures")
  map <- suppressWarnings(sf::st_simplify(map, dTolerance = 2500))
  boxes <- jpmap_inset_boxes(c("okinawa", "ogasawara"))
  limits <- jpmap_default_plot_limits()

  list(
    map = scale_coordinates(sf_coordinates(map), limits$xlim, limits$ylim),
    boxes = scale_coordinates(sf_coordinates(boxes), limits$xlim, limits$ylim)
  )
}

logo_plot <- function(include_text = TRUE) {
  data <- map_data()
  outer_hex <- hexagon(0.49)
  inner_hex <- hexagon(0.435)
  border_hex <- hexagon(0.455)

  plot <- ggplot() +
    geom_polygon(
      data = outer_hex,
      aes(x = x, y = y),
      fill = garnet,
      color = NA
    ) +
    geom_polygon(
      data = border_hex,
      aes(x = x, y = y),
      fill = gold,
      color = NA
    ) +
    geom_polygon(
      data = inner_hex,
      aes(x = x, y = y),
      fill = cream,
      color = NA
    ) +
    geom_polygon(
      data = data$map,
      aes(x = x, y = y, group = group),
      fill = garnet,
      color = "white",
      linewidth = 0.12,
      linejoin = "round"
    ) +
    geom_path(
      data = data$boxes,
      aes(x = x, y = y, group = group),
      color = gold,
      linewidth = 0.9,
      linejoin = "round"
    ) +
    coord_equal(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE, clip = "off") +
    theme_void(base_family = "sans") +
    theme(
      plot.background = element_rect(fill = "transparent", color = NA),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.margin = margin(0, 0, 0, 0)
    )

  if (isTRUE(include_text)) {
    plot <- plot +
      annotate(
        "text",
        x = 0.5,
        y = 0.175,
        label = "jpmap",
        family = "sans",
        fontface = "bold",
        size = 10.8,
        color = ink
      )
  }

  plot
}

save_png <- function(plot, path, size) {
  ggplot2::ggsave(
    filename = path,
    plot = plot,
    width = size / 96,
    height = size / 96,
    units = "in",
    dpi = 96,
    bg = "transparent",
    device = "png"
  )
}

save_svg <- function(plot, path) {
  png_file <- tempfile(fileext = ".png")
  save_png(plot, png_file, 512)
  encoded <- base64enc::base64encode(png_file)
  svg <- paste0(
    '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" ',
    'viewBox="0 0 512 512">',
    '<image width="512" height="512" href="data:image/png;base64,',
    encoded,
    '"/>',
    '</svg>'
  )
  writeLines(svg, path, useBytes = TRUE)
}

write_png_ico <- function(png_files, sizes, path) {
  images <- lapply(png_files, function(file) {
    readBin(file, "raw", n = file.info(file)$size)
  })
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)

  writeBin(as.integer(0), con, size = 2, endian = "little")
  writeBin(as.integer(1), con, size = 2, endian = "little")
  writeBin(as.integer(length(images)), con, size = 2, endian = "little")

  offset <- 6 + 16 * length(images)
  for (i in seq_along(images)) {
    size_byte <- if (sizes[[i]] >= 256) 0 else sizes[[i]]
    writeBin(as.integer(size_byte), con, size = 1)
    writeBin(as.integer(size_byte), con, size = 1)
    writeBin(as.integer(0), con, size = 1)
    writeBin(as.integer(0), con, size = 1)
    writeBin(as.integer(1), con, size = 2, endian = "little")
    writeBin(as.integer(32), con, size = 2, endian = "little")
    writeBin(as.integer(length(images[[i]])), con, size = 4, endian = "little")
    writeBin(as.integer(offset), con, size = 4, endian = "little")
    offset <- offset + length(images[[i]])
  }

  for (image in images) {
    writeBin(image, con)
  }
}

logo <- logo_plot(include_text = TRUE)
favicon <- logo_plot(include_text = FALSE)

save_png(logo, "man/figures/logo.png", 480)
save_png(logo, "docs/logo.png", 480)
save_png(logo, "docs/reference/figures/logo.png", 480)

save_svg(favicon, "pkgdown/favicon/favicon.svg")
save_svg(favicon, "docs/favicon.svg")

favicon_specs <- c(
  "apple-touch-icon.png" = 180,
  "favicon-96x96.png" = 96,
  "web-app-manifest-192x192.png" = 192,
  "web-app-manifest-512x512.png" = 512
)

for (file in names(favicon_specs)) {
  save_png(favicon, file.path("pkgdown/favicon", file), favicon_specs[[file]])
  save_png(favicon, file.path("docs", file), favicon_specs[[file]])
}

ico_dir <- tempfile("jpmap-favicon-ico-")
dir.create(ico_dir)
ico_sizes <- c(16, 32, 48)
ico_files <- file.path(ico_dir, paste0("favicon-", ico_sizes, ".png"))
for (i in seq_along(ico_files)) {
  save_png(favicon, ico_files[[i]], ico_sizes[[i]])
}
write_png_ico(ico_files, ico_sizes, "pkgdown/favicon/favicon.ico")
write_png_ico(ico_files, ico_sizes, "docs/favicon.ico")
