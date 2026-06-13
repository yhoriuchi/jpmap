\name{jp_us_military_bases}
\alias{jp_us_military_bases}
\title{Selected U.S. military installations in Japan}
\docType{data}
\description{
A sample data frame containing selected U.S. military installations in Japan
with longitude/latitude coordinates and public approximate personnel figures
where those figures have a clear source.
}
\format{
A data frame with 17 rows and 12 variables:
\describe{
\item{base}{Installation or command name.}
\item{branch}{Primary U.S. military branch.}
\item{prefecture}{Japanese prefecture.}
\item{municipality}{Municipality or municipalities.}
\item{lon}{Longitude in WGS84.}
\item{lat}{Latitude in WGS84.}
\item{personnel}{Approximate public personnel figure, when available.}
\item{personnel_scope}{What the public figure counts.}
\item{personnel_geography}{Whether the figure describes an installation,
regional total, command, or broader installation community.}
\item{personnel_is_base_specific}{Whether \code{personnel} is interpreted as a
base-specific figure.}
\item{source_url}{Source URL.}
\item{note}{Caveat for use in examples.}
}
}
\details{
These values are intended for examples and are not an official personnel
accounting. Some rows describe broader installation, regional, command, or
community populations; see \code{personnel_scope} and
\code{personnel_geography}.
}
\source{
Public installation, command, and regional pages listed in the \code{source_url}
column, including \url{https://en.wikipedia.org/wiki/Misawa_Air_Base},
\url{https://en.wikipedia.org/wiki/Yokota_Air_Base}, and
\url{https://en.wikipedia.org/wiki/Okinawa_Island}.
}
\keyword{datasets}
