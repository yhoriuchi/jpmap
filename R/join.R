#' Join user data to a jpmap boundary object
#'
#' `jp_map_join()` attaches columns from a user data frame to an `sf` object
#' returned by [jp_map()]. It is designed for common Japan-map keys, including
#' `pref_code`, `jis_code`, and `municipality_code`, and keeps leading zeroes
#' from getting in the user's way.
#'
#' @param map An `sf` object returned by [jp_map()].
#' @param data A data frame with one row per region to join.
#' @param by Join column. If `NULL`, `jpmap` guesses from common columns such as
#'   `jis_code`, `municipality_code`, `pref_code`, `prefecture`,
#'   `prefecture_ja`, `municipality`, and `municipality_ja`. To join columns
#'   with different names, use a named character vector such as
#'   `c("pref_code" = "code")`, where the name is the map column and the value
#'   is the data column.
#' @param values Optional column expected to exist after joining. This is useful
#'   when checking data before passing it to a plotting function.
#' @param unmatched What to do when user data rows do not match the map, or map
#'   regions do not receive a data row. One of `"warning"`, `"error"`, or
#'   `"ignore"`.
#' @param multiple What to do when `data` has duplicate join keys. One of
#'   `"error"` or `"first"`.
#'
#' @return An `sf` object with non-geometry columns from `data` joined to `map`.
#' @export
#'
#' @examples
#' if (requireNamespace("dplyr", quietly = TRUE) &&
#'     nrow(available_jpmap_data()) > 0) {
#'   data("jp_prefecture_gdp")
#'
#'   gdp <- jp_prefecture_gdp |>
#'     dplyr::select(pref_code, gdp_per_capita_jpy)
#'
#'   joined <- jp_map("prefecture") |>
#'     jp_map_join(gdp, by = "pref_code")
#'
#'   "gdp_per_capita_jpy" %in% names(joined)
#' }
jp_map_join <- function(map,
                        data,
                        by = NULL,
                        values = NULL,
                        unmatched = c("warning", "error", "ignore"),
                        multiple = c("error", "first")) {
  if (!inherits(map, "sf")) {
    stop("`map` must be an sf object returned by `jp_map()`.", call. = FALSE)
  }
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (nrow(data) == 0) {
    return(map)
  }

  unmatched <- match.arg(unmatched)
  multiple <- match.arg(multiple)
  join_cols <- resolve_join_columns(map, data, by)
  map_by <- join_cols$map
  data_by <- join_cols$data

  map_key <- jpmap_join_key(map[[map_by]], map_by)
  data_key <- jpmap_join_key(data[[data_by]], map_by)
  check_duplicate_join_keys(data_key, data_by, multiple)

  idx <- match(map_key, data_key)
  report_unmatched_join_keys(map_key, data_key, map_by, data_by, idx, unmatched)

  extra_cols <- setdiff(names(data), c(names(map), data_by))
  for (col in extra_cols) {
    map[[col]] <- data[[col]][idx]
  }

  if (!is.null(values) && !values %in% names(map)) {
    stop("`values` column not found after joining data: ", values, call. = FALSE)
  }

  map
}

resolve_join_columns <- function(map, data, by = NULL) {
  if (is.null(by)) {
    by <- guess_join_column(map, data)
    if (is.null(by)) {
      stop(
        "Could not find a join column. Use one of: jis_code, pref_code, ",
        "prefecture, prefecture_ja, municipality_code, municipality, ",
        "municipality_ja, or pass `by` explicitly.",
        call. = FALSE
      )
    }
  }

  if (!is.character(by) || length(by) != 1 || is.na(by) || !nzchar(by)) {
    stop("`by` must be NULL, a column name, or a named character vector of length 1.", call. = FALSE)
  }

  if (!is.null(names(by)) && nzchar(names(by))) {
    map_by <- names(by)
    data_by <- unname(by)
  } else {
    map_by <- unname(by)
    data_by <- unname(by)
  }

  if (!map_by %in% names(map)) {
    stop("Join column not found in `map`: ", map_by, call. = FALSE)
  }
  if (!data_by %in% names(data)) {
    stop("Join column not found in `data`: ", data_by, call. = FALSE)
  }

  list(map = map_by, data = data_by)
}

jpmap_join_key <- function(x, column) {
  if (column %in% c("pref_code")) {
    return(jpmap_code_key(x, width = 2))
  }
  if (column %in% c("jis_code", "municipality_code")) {
    return(jpmap_code_key(x, width = 5))
  }
  normalize_key(x)
}

jpmap_code_key <- function(x, width) {
  out <- trimws(as.character(x))
  is_code <- !is.na(out) & grepl("^[0-9]+$", out)
  out[is_code] <- sprintf(paste0("%0", width, "d"), as.integer(out[is_code]))
  out
}

check_duplicate_join_keys <- function(data_key, data_by, multiple) {
  non_missing <- data_key[!is.na(data_key)]
  duplicated_keys <- unique(non_missing[duplicated(non_missing)])
  if (length(duplicated_keys) == 0) {
    return(invisible(NULL))
  }

  message <- paste0(
    "`data` has duplicate join keys in `", data_by,
    "`. Aggregate to one row per map region before joining."
  )
  if (identical(multiple, "error")) {
    stop(message, call. = FALSE)
  }
  warning(message, " Keeping the first row for each key.", call. = FALSE)
  invisible(NULL)
}

report_unmatched_join_keys <- function(map_key,
                                       data_key,
                                       map_by,
                                       data_by,
                                       idx,
                                       unmatched) {
  if (identical(unmatched, "ignore")) {
    return(invisible(NULL))
  }

  data_unmatched <- unique(data_key[!is.na(data_key) & !data_key %in% map_key])
  map_unmatched <- unique(map_key[!is.na(map_key) & is.na(idx)])
  if (length(data_unmatched) == 0 && length(map_unmatched) == 0) {
    return(invisible(NULL))
  }

  parts <- character()
  if (length(data_unmatched) > 0) {
    parts <- c(parts, paste0(length(data_unmatched), " `data` key(s) in `", data_by, "` did not match the map"))
  }
  if (length(map_unmatched) > 0) {
    parts <- c(parts, paste0(length(map_unmatched), " map region key(s) in `", map_by, "` did not receive data"))
  }
  message <- paste(parts, collapse = "; ")

  if (identical(unmatched, "error")) {
    stop(message, call. = FALSE)
  }
  warning(message, call. = FALSE)
  invisible(NULL)
}
