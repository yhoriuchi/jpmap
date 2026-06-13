jpmap_data_dir <- function(create = TRUE) {
  path <- tools::R_user_dir("jpmap", "data")
  if (isTRUE(create)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  path
}

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

jp_map <- function(regions = c("prefectures", "prefecture", "municipalities", "municipality"),
                   include = c(),
                   exclude = c(),
                   data_year = NULL,
                   inset = TRUE,
                   okinawa = TRUE,
                   ogasawara = TRUE,
                   data_dir = NULL) {
  layer <- canonical_region(regions)
  path <- choose_jpmap_data(
    data_year,
    data_dir,
    regions = layer,
    include = include
  )

  map <- sf::st_read(path, layer = layer, quiet = TRUE)
  map <- filter_jpmap(map, layer, include, exclude)
  jpmap_transform(map, inset = inset, okinawa = okinawa, ogasawara = ogasawara)
}

jp_map_with_data <- function(map, data, values = NULL, by = NULL) {
  if (!inherits(map, "sf")) {
    stop("`map` must be an sf object returned by `jp_map()`.", call. = FALSE)
  }
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (nrow(data) == 0) {
    return(map)
  }

  by <- by %||% guess_join_column(map, data)
  if (is.null(by)) {
    stop(
      "Could not find a join column. Use one of: jis_code, pref_code, ",
      "prefecture, prefecture_ja, municipality_code, municipality, ",
      "or municipality_ja.",
      call. = FALSE
    )
  }

  idx <- match(as.character(map[[by]]), as.character(data[[by]]))
  extra_cols <- setdiff(names(data), names(map))

  for (col in extra_cols) {
    map[[col]] <- data[[col]][idx]
  }

  if (!is.null(values) && !values %in% names(map)) {
    stop("`values` column not found after joining data: ", values, call. = FALSE)
  }

  map
}

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
