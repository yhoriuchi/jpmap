\name{jp_us_military_bases}
\alias{jp_us_military_bases}
\title{Selected U.S. military installations in Japan}
\docType{data}
\description{
A sample data frame containing selected U.S. military installations in Japan
with public approximate personnel figures and longitude/latitude coordinates.
}
\format{
A data frame with 8 rows and 10 variables:
\describe{
\item{base}{Installation or command name.}
\item{branch}{Primary U.S. military branch.}
\item{prefecture}{Japanese prefecture.}
\item{municipality}{Municipality or municipalities.}
\item{lon}{Longitude in WGS84.}
\item{lat}{Latitude in WGS84.}
\item{personnel}{Approximate public personnel figure.}
\item{personnel_scope}{What the public figure counts.}
\item{source_url}{Source URL.}
\item{note}{Caveat for use in examples.}
}
}
\details{
These values are intended for examples and are not an official personnel
accounting. Some rows describe broader installation or command populations;
see \code{personnel_scope}.
}
\keyword{datasets}
