#' Manage jpmap Boundary Data
#'
#' Helpers for locating and building the GeoPackage boundary data used by
#' jpmap. The installed package includes example prefecture boundaries and
#' official MLIT N03 municipal boundaries for Okinawa Prefecture as of
#' January 1, 2024. Use `jpmap_build_data()` to build nationwide detailed
#' municipal boundaries, or `jpmap_build_data(prefecture = "Ehime")` to build
#' one prefecture from the official MLIT N03 administrative area data.
#'
#' @param create Whether to create the default data directory.
#' @param data_dir Optional directory to scan for boundary data.
#' @param year Boundary data year.
#' @param prefecture Optional prefecture code, English name, or Japanese name.
#'   When supplied, only that prefecture's official MLIT N03 file is downloaded
#'   and built.
#' @param destdir Directory where the generated GeoPackage should be written.
#' @param url Optional source URL. By default, an MLIT N03 URL is constructed.
#' @param overwrite Whether to overwrite an existing GeoPackage.
#' @param quiet Whether to suppress messages from download and spatial
#'   reads/writes.
#' @param simplify_tolerance Optional tolerance passed to [sf::st_simplify()].
#'
#' @return `jpmap_data_dir()` returns a path, `available_jpmap_data()` returns a
#'   data frame with `year`, `pref_code`, `prefecture`, and `path`, and
#'   `jpmap_build_data()` invisibly returns the generated file.
#' @source MLIT National Land Numerical Information N03 administrative area
#'   data: <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2024.html>.
#'
#' @examples
#' \dontrun{
#' jpmap_build_data(year = 2024)
#' jpmap_build_data(year = 2024, prefecture = "Ehime")
#' available_jpmap_data()
#' }
#' @export
#' @rdname jpmap_data
jpmap_data_dir <- function(create = TRUE) {
  path <- tools::R_user_dir("jpmap", "data")
  if (isTRUE(create)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  path
}

#' @export
#' @rdname jpmap_data
available_jpmap_data <- function(data_dir = NULL) {
  dirs <- jpmap_data_dirs(data_dir)
  files <- unlist(
    lapply(dirs, function(path) {
      if (!dir.exists(path)) {
        character()
      } else {
        list.files(
          path,
          pattern = "^jpmap_boundaries_[0-9]{4}(_[0-9]{2})?[.]gpkg$",
          full.names = TRUE
        )
      }
    }),
    use.names = FALSE
  )

  if (length(files) == 0) {
    return(data.frame(
      year = integer(),
      pref_code = character(),
      prefecture = character(),
      path = character()
    ))
  }

  file_names <- basename(files)
  years <- as.integer(sub("^jpmap_boundaries_([0-9]{4})(_[0-9]{2})?[.]gpkg$", "\\1", file_names))
  pref_code <- rep(NA_character_, length(file_names))
  has_pref_code <- grepl("^jpmap_boundaries_[0-9]{4}_[0-9]{2}[.]gpkg$", file_names)
  pref_code[has_pref_code] <- sub(
    "^jpmap_boundaries_[0-9]{4}_([0-9]{2})[.]gpkg$",
    "\\1",
    file_names[has_pref_code]
  )
  data.frame(
    year = years,
    pref_code = pref_code,
    prefecture = prefecture_name_from_code(pref_code),
    path = normalizePath(files, mustWork = FALSE)
  )
}

#' Retrieve Japan Map Data
#'
#' Reads Japan administrative boundary data and returns an `sf` object.
#'
#' @param regions Boundary level: prefectures or municipalities.
#' @param include Regions to include by code, English name, or Japanese name.
#' @param exclude Regions to exclude by code, English name, or Japanese name.
#' @param data_year Boundary data year. The newest appropriate available file
#'   is used by default. For example, national prefecture maps prefer a national
#'   file, while one-prefecture municipal requests can use a matching prefecture
#'   file.
#' @param inset Inset behavior. Use `TRUE` to move both Okinawa and Ogasawara,
#'   `FALSE` for no movement, or a character vector containing `"okinawa"`
#'   and/or `"ogasawara"` to move selected island groups.
#' @param okinawa Whether Okinawa should be moved when `inset` includes it.
#' @param ogasawara Whether Ogasawara should be moved when `inset` includes it.
#' @param territorial_disputes Whether to include disputed-territory
#'   island/reef shapes. Use `FALSE` to exclude them, or a character vector
#'   containing one or more of `"northern_territories"`, `"okinotorishima"`,
#'   `"senkaku"`, and `"takeshima"`.
#' @param data_dir Optional directory containing `jpmap_boundaries_YYYY.gpkg`.
#'
#' @return An `sf` data frame.
#' @export
#'
#' @examples
#' \dontrun{
#' jp_map("prefectures")
#' jp_map("prefectures", okinawa = FALSE)
#' jp_map("prefectures", territorial_disputes = FALSE)
#' jp_map("municipalities", include = "Okinawa")
#' jp_map("prefecture")
#' jp_map("municipality", include = "Okinawa")
#' }
jp_map <- function(regions = c("prefectures", "prefecture", "municipalities", "municipality"),
                   include = c(),
                   exclude = c(),
                   data_year = NULL,
                   inset = TRUE,
                   okinawa = TRUE,
                   ogasawara = TRUE,
                   territorial_disputes = TRUE,
                   data_dir = NULL) {
  layer <- canonical_region(regions)
  disputed_regions <- normalize_territorial_disputes(territorial_disputes)
  path <- choose_jpmap_data(
    data_year,
    data_dir,
    regions = layer,
    include = include
  )

  map <- sf::st_read(path, layer = layer, quiet = TRUE)
  map <- filter_jpmap(map, layer, include, exclude)
  map <- remove_disputed_territories(map)
  if (length(disputed_regions) > 0) {
    map <- add_disputed_territories(
      map,
      layer,
      disputed_regions,
      include = include,
      exclude = exclude
    )
  }
  jpmap_transform(map, inset = inset, okinawa = okinawa, ogasawara = ogasawara)
}

#' Retrieve Disputed-Territory Island And Reef Shapes
#'
#' Returns cartographic island/reef shapes for disputed territories or disputed
#' maritime/EEZ-status areas discussed in Japan territorial-dispute references.
#' These geometries are intentionally separate from the MLIT N03 administrative
#' boundary data and are not authoritative legal boundary polygons.
#'
#' @param territorial_disputes Which disputed-territory shapes to include. Use
#'   `TRUE` for all built-in shapes, `FALSE` for none, or a character vector
#'   containing one or more of `"northern_territories"`, `"okinotorishima"`,
#'   `"senkaku"`, and `"takeshima"`. Common aliases such as `"kuril"`,
#'   `"liancourt"`, `"dokdo"`, and `"diaoyu"` are also accepted.
#' @param regions Boundary level whose columns should be mirrored: prefectures
#'   or municipalities.
#' @param inset Inset behavior. Use `TRUE` to move Okinawa and Ogasawara,
#'   `FALSE` for literal projected locations, or a character vector containing
#'   `"okinawa"` and/or `"ogasawara"`.
#' @param okinawa Whether Okinawa should be moved when `inset` includes it.
#' @param ogasawara Whether Ogasawara should be moved when `inset` includes it.
#'
#' @return An `sf` data frame.
#' @source Territory list based on
#'   <https://en.wikipedia.org/wiki/Territorial_disputes_of_Japan>. Shapes are
#'   derived from Natural Earth 1:10m land polygons and OpenStreetMap geometry.
#' @export
#'
#' @examples
#' \dontrun{
#' jp_disputed_territories()
#' jp_disputed_territories(c("senkaku", "takeshima"))
#' }
jp_disputed_territories <- function(territorial_disputes = TRUE,
                                    regions = c("prefectures", "prefecture", "municipalities", "municipality"),
                                    inset = TRUE,
                                    okinawa = TRUE,
                                    ogasawara = TRUE) {
  layer <- canonical_region(regions)
  disputed_regions <- normalize_territorial_disputes(territorial_disputes)
  if (length(disputed_regions) == 0) {
    return(empty_disputed_territories(layer))
  }

  territories <- disputed_territories_sf(layer, disputed_regions)
  jpmap_transform(territories, inset = inset, okinawa = okinawa, ogasawara = ogasawara)
}

#' Join Data to a jpmap Map
#'
#' Joins user data to a Japan map object. This is a compact wrapper around
#' [jp_map_join()] kept for plotting workflows that call it internally.
#'
#' @param map An `sf` object returned by [jp_map()].
#' @param data A data frame containing a matching administrative code or name
#'   column.
#' @param values Optional value column to check after joining.
#' @param by Optional join column. If omitted, jpmap guesses from common
#'   columns.
#'
#' @return An `sf` object.
#' @export
jp_map_with_data <- function(map, data, values = NULL, by = NULL) {
  jp_map_join(map, data, by = by, values = values)
}

#' @export
#' @rdname jpmap_data
jpmap_build_data <- function(year = 2024,
                             prefecture = NULL,
                             destdir = jpmap_data_dir(),
                             url = NULL,
                             overwrite = FALSE,
                             quiet = FALSE,
                             simplify_tolerance = NULL) {
  if (!requireNamespace("utils", quietly = TRUE)) {
    stop("The utils package is required.", call. = FALSE)
  }

  year <- as.integer(year[[1]])
  if (is.na(year)) {
    stop("`year` must be a four-digit year.", call. = FALSE)
  }

  pref_code <- prefecture_code_from_input(prefecture)
  url <- url %||% n03_source_url(year, pref_code)
  dir.create(destdir, recursive = TRUE, showWarnings = FALSE)
  file_suffix <- if (is.null(pref_code)) "" else paste0("_", pref_code)
  dest <- file.path(destdir, sprintf("jpmap_boundaries_%s%s.gpkg", year, file_suffix))

  if (file.exists(dest) && !isTRUE(overwrite)) {
    stop(
      "Data file already exists: ", dest,
      ". Use `overwrite = TRUE` to rebuild it.",
      call. = FALSE
    )
  }

  tmp <- tempfile("jpmap-n03-")
  dir.create(tmp)
  zipfile <- file.path(tmp, basename(url))

  if (!quiet) {
    message("Downloading administrative boundary data from: ", url)
  }
  utils::download.file(url, zipfile, mode = "wb", quiet = quiet)
  utils::unzip(zipfile, exdir = tmp)

  boundary_file <- find_boundary_file(tmp)
  if (!quiet) {
    message("Reading: ", boundary_file)
  }
  raw <- sf::st_read(boundary_file, quiet = quiet)
  municipalities <- standardize_n03(raw)
  municipalities <- sf::st_transform(municipalities, 4326)

  if (!is.null(simplify_tolerance)) {
    municipalities <- sf::st_simplify(
      municipalities,
      dTolerance = simplify_tolerance,
      preserveTopology = TRUE
    )
  }

  prefectures <- aggregate_prefectures(municipalities)

  if (file.exists(dest)) {
    unlink(dest)
  }
  sf::st_write(prefectures, dest, layer = "prefectures", quiet = quiet)
  sf::st_write(municipalities, dest, layer = "municipalities", append = TRUE, quiet = quiet)

  if (!quiet) {
    message("Wrote jpmap data: ", dest)
  }

  invisible(dest)
}

canonical_region <- function(regions) {
  regions <- match.arg(
    regions,
    choices = c("prefectures", "prefecture", "municipalities", "municipality")
  )
  switch(
    regions,
    prefecture = "prefectures",
    municipality = "municipalities",
    regions
  )
}

jpmap_data_dirs <- function(data_dir = NULL) {
  if (!is.null(data_dir)) {
    return(unique(data_dir))
  }

  package_dir <- system.file("extdata", package = "jpmap", mustWork = FALSE)
  unique(c(package_dir, jpmap_data_dir(create = FALSE)))
}

choose_jpmap_data <- function(data_year = NULL,
                              data_dir = NULL,
                              regions = NULL,
                              include = c()) {
  available <- available_jpmap_data(data_dir)
  if (nrow(available) == 0) {
    stop_missing_jpmap_data(data_dir)
  }

  available <- available[order(available$year, is.na(available$pref_code), decreasing = TRUE), , drop = FALSE]
  requested_pref_code <- requested_prefecture_code(regions, include)

  if (is.null(data_year)) {
    preferred <- preferred_data_path(available, requested_pref_code)
    return(preferred %||% available$path[[1]])
  }

  data_year <- as.integer(data_year[[1]])
  exact <- available[available$year == data_year, , drop = FALSE]
  if (nrow(exact) > 0) {
    preferred <- preferred_data_path(exact, requested_pref_code)
    return(preferred %||% exact$path[[1]])
  }

  older <- available[available$year <= data_year, , drop = FALSE]
  if (nrow(older) > 0) {
    preferred <- preferred_data_path(older, requested_pref_code)
    return(preferred %||% older$path[[1]])
  }

  preferred <- preferred_data_path(available, requested_pref_code)
  preferred %||% available$path[[1]]
}

preferred_data_path <- function(available, requested_pref_code = NULL) {
  if (!is.null(requested_pref_code)) {
    prefecture_file <- available[available$pref_code == requested_pref_code, , drop = FALSE]
    if (nrow(prefecture_file) > 0) {
      return(prefecture_file$path[[1]])
    }
  }

  national_file <- available[is.na(available$pref_code), , drop = FALSE]
  if (nrow(national_file) > 0) {
    return(national_file$path[[1]])
  }

  NULL
}

requested_prefecture_code <- function(regions = NULL, include = c()) {
  if (length(include) != 1) {
    return(NULL)
  }

  code <- tryCatch(
    prefecture_code_from_input(include),
    error = function(e) NULL
  )
  if (is.null(code)) {
    return(NULL)
  }

  code
}

stop_missing_jpmap_data <- function(data_dir = NULL) {
  dirs <- jpmap_data_dirs(data_dir)
  stop(
    "No jpmap boundary data was found. Build it with ",
    "`jpmap_build_data()` or place a `jpmap_boundaries_YYYY.gpkg` ",
    "or `jpmap_boundaries_YYYY_PP.gpkg` file in one of these directories: ",
    paste(dirs[nzchar(dirs)], collapse = ", "),
    call. = FALSE
  )
}

n03_source_url <- function(year, pref_code = NULL) {
  base <- sprintf(
    "https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-%s",
    year
  )
  if (is.null(pref_code)) {
    file_name <- sprintf("N03-%s0101_GML.zip", year)
  } else {
    file_name <- sprintf("N03-%s0101_%s_GML.zip", year, pref_code)
  }
  paste(base, file_name, sep = "/")
}

prefecture_code_from_input <- function(prefecture = NULL) {
  if (is.null(prefecture)) {
    return(NULL)
  }
  if (length(prefecture) != 1) {
    stop("`prefecture` must be NULL or a single prefecture code/name.", call. = FALSE)
  }

  x <- as.character(prefecture)
  if (is.na(x) || !nzchar(x)) {
    stop("`prefecture` must be NULL or a single prefecture code/name.", call. = FALSE)
  }
  if (grepl("^[0-9]{1,2}$", x)) {
    code <- sprintf("%02d", as.integer(x))
    if (code %in% jp_prefectures$pref_code) {
      return(code)
    }
  }

  key <- normalize_key(x)
  idx <- match(key, normalize_key(jp_prefectures$prefecture))
  if (is.na(idx)) {
    idx <- match(key, normalize_key(jp_prefectures$prefecture_ja))
  }
  if (is.na(idx)) {
    stop("Unknown prefecture: ", x, call. = FALSE)
  }

  jp_prefectures$pref_code[[idx]]
}

filter_jpmap <- function(map, regions, include, exclude) {
  include <- as.character(include)
  exclude <- as.character(exclude)

  include_match <- match_admin_values(map, regions, include)
  exclude_match <- match_admin_values(map, regions, exclude)

  if (length(include) > 0) {
    missing <- include[!vapply(include, function(x) any(match_admin_values(map, regions, x)), logical(1))]
    if (length(missing) > 0) {
      warning("No matching regions found for include value(s): ", paste(missing, collapse = ", "))
    }
    keep <- include_match
  } else if (length(exclude) > 0) {
    keep <- !exclude_match
  } else {
    keep <- rep(TRUE, nrow(map))
  }

  map[keep, , drop = FALSE]
}

add_disputed_territories <- function(map,
                                     layer,
                                     disputed_regions,
                                     include = c(),
                                     exclude = c()) {
  disputes <- disputed_territories_sf(layer, disputed_regions)
  disputes <- filter_disputed_territories(disputes, layer, include, exclude)
  disputes <- sf::st_transform(disputes, sf::st_crs(map))
  disputes <- match_sf_geometry_column(disputes, map)

  missing_cols <- setdiff(names(map), names(disputes))
  for (col in missing_cols) {
    disputes[[col]] <- NA
  }
  extra_cols <- setdiff(names(disputes), names(map))
  for (col in extra_cols) {
    map[[col]] <- NA
  }
  disputes <- disputes[names(map)]

  rbind(map, disputes)
}

filter_disputed_territories <- function(disputes, layer, include = c(), exclude = c()) {
  include <- as.character(include)
  exclude <- as.character(exclude)

  if (length(include) > 0) {
    keep <- match_disputed_values(disputes, layer, include)
  } else if (length(exclude) > 0) {
    keep <- !match_disputed_values(disputes, layer, exclude)
  } else {
    keep <- rep(TRUE, nrow(disputes))
  }

  disputes[keep, , drop = FALSE]
}

remove_disputed_territories <- function(map) {
  disputes <- disputed_territory_source()
  if (nrow(disputes) == 0) {
    return(map)
  }

  source_crs <- sf::st_crs(map)
  projected <- sf::st_transform(map, jpmap_crs())
  erase <- sf::st_geometry(sf::st_transform(disputes, jpmap_crs()))
  erase <- sf::st_buffer(sf::st_union(erase), dist = 100)
  if (inherits(erase, "sfc")) {
    erase <- erase[[1]]
  }
  erase <- sf::st_sfc(erase, crs = jpmap_crs())
  geometries <- sf::st_geometry(projected)
  hits <- lengths(sf::st_intersects(geometries, erase)) > 0
  if (!any(hits)) {
    return(sf::st_transform(projected, source_crs))
  }
  geometries[hits] <- sf::st_sfc(
    lapply(geometries[hits], function(geometry) {
      out <- suppressWarnings(sf::st_difference(
        sf::st_sfc(geometry, crs = jpmap_crs()),
        erase
      ))
      if (length(out) == 0) {
        return(sf::st_geometrycollection())
      }
      out[[1]]
    }),
    crs = jpmap_crs()
  )
  sf::st_geometry(projected) <- geometries
  projected <- projected[!sf::st_is_empty(projected), , drop = FALSE]
  sf::st_transform(projected, source_crs)
}

match_sf_geometry_column <- function(x, template) {
  template_geometry <- attr(template, "sf_column")
  x_geometry <- attr(x, "sf_column")
  if (!identical(x_geometry, template_geometry)) {
    names(x)[names(x) == x_geometry] <- template_geometry
    attr(x, "sf_column") <- template_geometry
  }
  x
}

empty_disputed_territories <- function(layer) {
  disputed_territories_sf(layer, character())
}

normalize_territorial_disputes <- function(territorial_disputes = TRUE) {
  all_regions <- c("northern_territories", "okinotorishima", "senkaku", "takeshima")

  if (is.null(territorial_disputes)) {
    return(character())
  }

  if (is.logical(territorial_disputes)) {
    if (length(territorial_disputes) != 1 || is.na(territorial_disputes)) {
      stop("`territorial_disputes` must be TRUE, FALSE, or a character vector.", call. = FALSE)
    }
    if (isTRUE(territorial_disputes)) {
      return(all_regions)
    }
    return(character())
  }

  if (!is.character(territorial_disputes)) {
    stop("`territorial_disputes` must be TRUE, FALSE, or a character vector.", call. = FALSE)
  }
  if (length(territorial_disputes) == 0) {
    return(character())
  }

  keys <- normalize_key(territorial_disputes)
  keys[keys %in% c("all", "true", "yes")] <- "all"
  if ("all" %in% keys) {
    return(all_regions)
  }
  if (any(keys %in% c("none", "false", "no"))) {
    return(character())
  }

  aliases <- c(
    northernterritories = "northern_territories",
    northernterritory = "northern_territories",
    kuril = "northern_territories",
    kurils = "northern_territories",
    kurilislands = "northern_territories",
    etorofu = "northern_territories",
    iturup = "northern_territories",
    kunashiri = "northern_territories",
    kunashir = "northern_territories",
    shikotan = "northern_territories",
    habomai = "northern_territories",
    okinotorishima = "okinotorishima",
    okinotorishimaisland = "okinotorishima",
    senkaku = "senkaku",
    senkakuislands = "senkaku",
    diaoyu = "senkaku",
    diaoyuislands = "senkaku",
    takeshima = "takeshima",
    liancourt = "takeshima",
    liancourtrocks = "takeshima",
    dokdo = "takeshima"
  )

  normalized <- unname(aliases[keys])
  invalid <- territorial_disputes[is.na(normalized)]
  if (length(invalid) > 0) {
    stop(
      "`territorial_disputes` must be TRUE, FALSE, or one or more of: ",
      paste(all_regions, collapse = ", "),
      call. = FALSE
    )
  }

  unique(normalized)
}

disputed_territories_sf <- function(layer, disputed_regions) {
  specs <- disputed_territory_source()
  specs <- specs[specs$dispute_region %in% disputed_regions, , drop = FALSE]

  if (nrow(specs) == 0) {
    data <- disputed_territory_rows(layer, specs)
    return(sf::st_sf(data, geometry = sf::st_sfc(crs = 4326)))
  }

  data <- disputed_territory_rows(layer, specs)
  sf::st_sf(data, geometry = sf::st_geometry(specs), crs = sf::st_crs(specs))
}

disputed_territory_source <- function() {
  path <- system.file(
    "extdata",
    "jpmap_disputed_territories.gpkg",
    package = "jpmap"
  )
  if (!nzchar(path)) {
    dev_path <- file.path("inst", "extdata", "jpmap_disputed_territories.gpkg")
    if (file.exists(dev_path)) {
      path <- dev_path
    }
  }
  if (!nzchar(path) || !file.exists(path)) {
    stop("Could not find bundled disputed-territory geometry data.", call. = FALSE)
  }
  sf::st_read(path, layer = "territorial_disputes", quiet = TRUE)
}

disputed_territory_rows <- function(layer, specs) {
  n <- nrow(specs)
  claims <- disputed_territory_claims(specs$dispute_region)
  if (n == 0) {
    data <- data.frame(
      jis_code = character(),
      pref_code = character(),
      prefecture = character(),
      prefecture_ja = character(),
      is_disputed_territory = logical(),
      dispute_region = character(),
      territory = character(),
      territory_ja = character(),
      claimed_pref_code = character(),
      claimed_prefecture = character(),
      claimed_prefecture_ja = character(),
      source = character(),
      source_url = character(),
      note = character(),
      stringsAsFactors = FALSE
    )
    if (identical(layer, "municipalities")) {
      data$municipality_code <- character()
      data$municipality <- character()
      data$municipality_ja <- character()
      data$municipality_full_ja <- character()
      data$claimed_municipality_code <- character()
      data$claimed_municipality <- character()
      data$claimed_municipality_ja <- character()
    }
    return(data)
  }

  data <- data.frame(
    jis_code = paste0("disputed_", specs$dispute_region),
    pref_code = rep(NA_character_, n),
    prefecture = specs$name_en,
    prefecture_ja = specs$name_ja,
    is_disputed_territory = rep(TRUE, n),
    dispute_region = specs$dispute_region,
    territory = specs$name_en,
    territory_ja = specs$name_ja,
    claimed_pref_code = claims$claimed_pref_code,
    claimed_prefecture = claims$claimed_prefecture,
    claimed_prefecture_ja = claims$claimed_prefecture_ja,
    source = specs$source,
    source_url = specs$source_url,
    note = specs$note,
    stringsAsFactors = FALSE
  )

  if (identical(layer, "municipalities")) {
    data$municipality_code <- data$jis_code
    data$municipality <- data$territory
    data$municipality_ja <- data$territory_ja
    data$municipality_full_ja <- data$territory_ja
    data$claimed_municipality_code <- claims$claimed_municipality_code
    data$claimed_municipality <- claims$claimed_municipality
    data$claimed_municipality_ja <- claims$claimed_municipality_ja
  }

  data
}

disputed_territory_claims <- function(dispute_region) {
  claims <- data.frame(
    dispute_region = c("northern_territories", "okinotorishima", "senkaku", "takeshima"),
    claimed_pref_code = c("01", "13", "47", "32"),
    claimed_prefecture = c("Hokkaido", "Tokyo", "Okinawa", "Shimane"),
    claimed_prefecture_ja = c("\u5317\u6d77\u9053", "\u6771\u4eac\u90fd", "\u6c96\u7e04\u770c", "\u5cf6\u6839\u770c"),
    claimed_municipality_code = c(NA_character_, "13421", "47207", "32528"),
    claimed_municipality = c(NA_character_, "Ogasawara", "Ishigaki", "Okinoshima"),
    claimed_municipality_ja = c(NA_character_, "\u5c0f\u7b20\u539f\u6751", "\u77f3\u57a3\u5e02", "\u96a0\u5c90\u306e\u5cf6\u753a"),
    stringsAsFactors = FALSE
  )
  claims[match(dispute_region, claims$dispute_region), , drop = FALSE]
}

match_disputed_values <- function(disputes, layer, values) {
  if (length(values) == 0 || nrow(disputes) == 0) {
    return(rep(FALSE, nrow(disputes)))
  }

  cols <- c(
    "dispute_region",
    "territory",
    "territory_ja",
    "claimed_pref_code",
    "claimed_prefecture",
    "claimed_prefecture_ja"
  )
  if (identical(layer, "municipalities")) {
    cols <- c(
      cols,
      "claimed_municipality_code",
      "claimed_municipality",
      "claimed_municipality_ja"
    )
  }
  cols <- cols[cols %in% names(disputes)]

  keys <- normalize_key(values)
  hit <- rep(FALSE, nrow(disputes))
  for (col in cols) {
    hit <- hit | normalize_key(disputes[[col]]) %in% keys
  }
  hit
}

match_admin_values <- function(map, regions, values) {
  if (length(values) == 0) {
    return(rep(FALSE, nrow(map)))
  }

  cols <- c("jis_code", "pref_code", "prefecture", "prefecture_ja")
  if (identical(regions, "municipalities")) {
    cols <- c(
      cols,
      "municipality_code",
      "municipality",
      "municipality_ja",
      "municipality_full_ja"
    )
  }
  cols <- cols[cols %in% names(map)]

  keys <- normalize_key(values)
  hit <- rep(FALSE, nrow(map))
  for (col in cols) {
    hit <- hit | normalize_key(map[[col]]) %in% keys
  }
  hit
}

guess_join_column <- function(map, data) {
  candidates <- c(
    "jis_code",
    "municipality_code",
    "pref_code",
    "prefecture",
    "prefecture_ja",
    "municipality",
    "municipality_ja",
    "municipality_full_ja"
  )
  common <- candidates[candidates %in% names(map) & candidates %in% names(data)]
  if (length(common) == 0) {
    NULL
  } else {
    common[[1]]
  }
}

find_boundary_file <- function(path) {
  candidates <- list.files(
    path,
    pattern = "[.](shp|geojson|gpkg|gml)$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE
  )
  if (length(candidates) == 0) {
    stop("No readable boundary file was found in the downloaded archive.", call. = FALSE)
  }
  shp <- candidates[grepl("[.]shp$", candidates, ignore.case = TRUE)]
  if (length(shp) > 0) {
    return(shp[[1]])
  }
  candidates[[1]]
}

standardize_n03 <- function(raw) {
  n03 <- names(raw)
  required <- c("N03_001", "N03_004", "N03_007")
  missing <- setdiff(required, n03)
  if (length(missing) > 0) {
    stop(
      "The boundary file does not look like MLIT N03 administrative area data. ",
      "Missing field(s): ", paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  pref_ja <- as.character(raw[["N03_001"]])
  muni_ja <- as.character(raw[["N03_004"]])
  code <- as.character(raw[["N03_007"]])
  district <- if ("N03_003" %in% n03) as.character(raw[["N03_003"]]) else rep(NA_character_, length(code))
  district[is.na(district)] <- ""
  muni_ja[is.na(muni_ja)] <- ""

  pref_code <- substr(code, 1, 2)
  municipality_full_ja <- ifelse(nzchar(district), paste0(district, muni_ja), muni_ja)

  out <- sf::st_sf(
    data.frame(
      jis_code = code,
      pref_code = pref_code,
      prefecture = prefecture_name_from_code(pref_code),
      prefecture_ja = pref_ja,
      municipality_code = code,
      municipality_ja = muni_ja,
      municipality_full_ja = municipality_full_ja,
      stringsAsFactors = FALSE
    ),
    geometry = sf::st_geometry(raw),
    crs = sf::st_crs(raw)
  )

  out
}

aggregate_prefectures <- function(municipalities) {
  split_idx <- split(seq_len(nrow(municipalities)), municipalities$pref_code)

  rows <- lapply(split_idx, function(idx) {
    first <- idx[[1]]
    geometry <- sf::st_union(sf::st_geometry(municipalities[idx, ]))
    data <- data.frame(
      jis_code = municipalities$pref_code[[first]],
      pref_code = municipalities$pref_code[[first]],
      prefecture = municipalities$prefecture[[first]],
      prefecture_ja = municipalities$prefecture_ja[[first]],
      stringsAsFactors = FALSE
    )

    sf::st_sf(data, geometry = sf::st_sfc(geometry, crs = sf::st_crs(municipalities)))
  })

  do.call(rbind, rows)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
