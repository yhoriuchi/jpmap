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
"jp_prefecture_gdp"

#' Selected U.S. military installations in Japan
#'
#' A sample data frame containing selected U.S. military installations in Japan
#' with public approximate personnel figures and longitude/latitude coordinates.
#'
#' These values are intended for examples and are not an official personnel
#' accounting. Some rows describe broader installation or command populations;
#' see `personnel_scope`.
#'
#' @format A data frame with 8 rows and 10 variables:
#' \describe{
#'   \item{base}{Installation or command name.}
#'   \item{branch}{Primary U.S. military branch.}
#'   \item{prefecture}{Japanese prefecture.}
#'   \item{municipality}{Municipality or municipalities.}
#'   \item{lon}{Longitude in WGS84.}
#'   \item{lat}{Latitude in WGS84.}
#'   \item{personnel}{Approximate public personnel figure.}
#'   \item{personnel_scope}{What the public figure counts.}
#'   \item{source_url}{Source URL.}
#'   \item{note}{Caveat for use in examples.}
#' }
"jp_us_military_bases"
