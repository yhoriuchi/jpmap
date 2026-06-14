\name{jp_map_join}
\alias{jp_map_join}
\title{Join User Data to a jpmap Boundary Object}
\usage{
jp_map_join(
  map,
  data,
  by = NULL,
  values = NULL,
  unmatched = c("warning", "error", "ignore"),
  multiple = c("error", "first")
)
}
\arguments{
\item{map}{An \code{sf} object returned by \code{jp_map()}.}
\item{data}{A data frame with one row per region to join.}
\item{by}{Join column. If \code{NULL}, \code{jpmap} guesses from common
columns such as \code{jis_code}, \code{municipality_code}, \code{pref_code},
\code{prefecture}, \code{prefecture_ja}, \code{municipality}, and
\code{municipality_ja}. To join columns with different names, use a named
character vector such as \code{c("pref_code" = "code")}, where the name is the
map column and the value is the data column.}
\item{values}{Optional column expected to exist after joining. This is useful
when checking data before passing it to a plotting function.}
\item{unmatched}{What to do when user data rows do not match the map, or map
regions do not receive a data row. One of \code{"warning"}, \code{"error"}, or
\code{"ignore"}.}
\item{multiple}{What to do when \code{data} has duplicate join keys. One of
\code{"error"} or \code{"first"}.}
}
\value{
An \code{sf} object with non-geometry columns from \code{data} joined to
\code{map}.
}
\description{
\code{jp_map_join()} attaches columns from a user data frame to an \code{sf}
object returned by \code{jp_map()}. It is designed for common Japan-map keys,
including \code{pref_code}, \code{jis_code}, and \code{municipality_code}, and
keeps leading zeroes from getting in the user's way.
}
\examples{
if (requireNamespace("dplyr", quietly = TRUE) &&
    nrow(available_jpmap_data()) > 0) {
  data("jp_prefecture_gdp")

  gdp <- jp_prefecture_gdp |>
    dplyr::select(pref_code, gdp_per_capita_jpy)

  joined <- jp_map("prefecture") |>
    jp_map_join(gdp, by = "pref_code")

  "gdp_per_capita_jpy" \%in\% names(joined)
}
}
