#' GDP per capita by Japanese prefecture
#'
#' A sample data frame containing 2021 prefecture GDP per capita values.
#'
#' @format A data frame with 47 rows and 6 variables:
#' \describe{
#'   \item{pref_code}{Two-digit Japanese prefecture code.}
#'   \item{prefecture}{Prefecture name in English.}
#'   \item{year}{Reference year.}
#'   \item{gdp_per_capita_jpy}{GDP per capita in Japanese yen.}
#'   \item{gdp_per_capita_usd_ppp}{GDP per capita in U.S. dollars at PPP.}
#'   \item{source}{Source note.}
#' }
#' @source OECD 2021 regional GDP per-capita values as tabulated at
#'   <https://en.wikipedia.org/wiki/List_of_Japanese_prefectures_by_GDP_per_capita>.
"jp_prefecture_gdp"

#' Selected U.S. military installations in Japan
#'
#' A sample data frame containing selected U.S. military installations in Japan
#' with longitude/latitude coordinates and public approximate personnel figures
#' where those figures have a clear source.
#'
#' These values are intended for examples and are not an official personnel
#' accounting. Some rows describe broader installation or command populations;
#' see `personnel_scope` and `personnel_geography`.
#'
#' @format A data frame with 17 rows and 12 variables:
#' \describe{
#'   \item{base}{Installation or command name.}
#'   \item{branch}{Primary U.S. military branch.}
#'   \item{prefecture}{Japanese prefecture.}
#'   \item{municipality}{Municipality or municipalities.}
#'   \item{lon}{Longitude in WGS84.}
#'   \item{lat}{Latitude in WGS84.}
#'   \item{personnel}{Approximate public personnel figure, when available.}
#'   \item{personnel_scope}{What the public figure counts.}
#'   \item{personnel_geography}{Whether the figure describes an installation,
#'     regional total, command, or broader installation community.}
#'   \item{personnel_is_base_specific}{Whether `personnel` is interpreted as a
#'     base-specific figure.}
#'   \item{source_url}{Source URL.}
#'   \item{note}{Caveat for use in examples.}
#' }
#' @source Public installation, command, and regional pages listed in the
#'   `source_url` column, including pages such as
#'   <https://en.wikipedia.org/wiki/Misawa_Air_Base>,
#'   <https://en.wikipedia.org/wiki/Yokota_Air_Base>, and
#'   <https://en.wikipedia.org/wiki/Okinawa_Island>.
"jp_us_military_bases"
