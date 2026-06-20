\name{jp_disputed_territories}
\alias{jp_disputed_territories}
\title{Retrieve Disputed-Territory Island And Reef Shapes}
\usage{
jp_disputed_territories(
  territorial_disputes = TRUE,
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE
)
}
\arguments{
\item{territorial_disputes}{Which disputed-territory shapes to include.
Use \code{TRUE} for all built-in shapes, \code{FALSE} for none, or a
character vector containing one or more of \code{"northern_territories"},
\code{"okinotorishima"}, \code{"senkaku"}, and \code{"takeshima"}. Common
aliases such as \code{"kuril"}, \code{"liancourt"}, \code{"dokdo"}, and
\code{"diaoyu"} are also accepted.}
\item{regions}{Boundary level whose columns should be mirrored:
prefectures or municipalities.}
\item{inset}{Inset behavior. Use \code{TRUE} to move Okinawa and Ogasawara,
\code{FALSE} for literal projected locations, or a character vector
containing \code{"okinawa"} and/or \code{"ogasawara"}.}
\item{okinawa}{Whether Okinawa should be moved when \code{inset} includes it.}
\item{ogasawara}{Whether Ogasawara should be moved when \code{inset} includes it.}
}
\description{
Returns cartographic island/reef shapes for disputed territories or disputed
maritime/EEZ-status areas discussed in Japan territorial-dispute references.
These geometries are intentionally separate from the MLIT N03 administrative
boundary data and are not authoritative legal boundary polygons.
}
\value{
An \code{sf} data frame.
}
\source{
Territory list based on
\url{https://en.wikipedia.org/wiki/Territorial_disputes_of_Japan}.
Shapes are derived from Natural Earth 1:10m land polygons and OpenStreetMap
geometry.
}
\examples{
jp_disputed_territories()
jp_disputed_territories(c("senkaku", "takeshima"))
}
