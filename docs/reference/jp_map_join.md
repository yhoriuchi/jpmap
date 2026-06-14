# Join User Data to a jpmap Boundary Object

`jp_map_join()` attaches columns from a user data frame to an `sf`
object returned by
[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md). It
is designed for common Japan-map keys, including `pref_code`,
`jis_code`, and `municipality_code`, and keeps leading zeroes from
getting in the user's way.

## Usage

``` r
jp_map_join(
  map,
  data,
  by = NULL,
  values = NULL,
  unmatched = c("warning", "error", "ignore"),
  multiple = c("error", "first")
)
```

## Arguments

- map:

  An `sf` object returned by
  [`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md).

- data:

  A data frame with one row per region to join.

- by:

  Join column. If `NULL`, `jpmap` guesses from common columns such as
  `jis_code`, `municipality_code`, `pref_code`, `prefecture`,
  `prefecture_ja`, `municipality`, and `municipality_ja`. To join
  columns with different names, use a named character vector such as
  `c("pref_code" = "code")`, where the name is the map column and the
  value is the data column.

- values:

  Optional column expected to exist after joining. This is useful when
  checking data before passing it to a plotting function.

- unmatched:

  What to do when user data rows do not match the map, or map regions do
  not receive a data row. One of `"warning"`, `"error"`, or `"ignore"`.

- multiple:

  What to do when `data` has duplicate join keys. One of `"error"` or
  `"first"`.

## Value

An `sf` object with non-geometry columns from `data` joined to `map`.

## Examples

``` r
if (requireNamespace("dplyr", quietly = TRUE) &&
    nrow(available_jpmap_data()) > 0) {
  data("jp_prefecture_gdp")

  gdp <- jp_prefecture_gdp |>
    dplyr::select(pref_code, gdp_per_capita_jpy)

  joined <- jp_map("prefecture") |>
    jp_map_join(gdp, by = "pref_code")

  "gdp_per_capita_jpy" %in% names(joined)
}
#> [1] TRUE
```
