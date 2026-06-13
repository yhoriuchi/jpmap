\name{jp_map}
\alias{jp_map}
\title{Retrieve Japan Map Data}
\usage{
jp_map(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data_year = NULL,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE,
  data_dir = NULL
)
}
\arguments{
\item{regions}{Boundary level: prefectures or municipalities.}
\item{include}{Regions to include by code, English name, or Japanese name.}
\item{exclude}{Regions to exclude by code, English name, or Japanese name.}
\item{data_year}{Boundary data year. The newest appropriate available file is
used by default. For example, national prefecture maps prefer a national file,
while one-prefecture municipal requests can use a matching prefecture file.}
\item{inset}{Inset behavior. Use \code{TRUE} to move both Okinawa and
Ogasawara, \code{FALSE} for no movement, or a character vector containing
\code{"okinawa"} and/or \code{"ogasawara"} to move selected island groups.}
\item{okinawa}{Whether Okinawa should be moved when \code{inset} includes it.}
\item{ogasawara}{Whether Ogasawara should be moved when \code{inset} includes it.}
\item{data_dir}{Optional directory containing \code{jpmap_boundaries_YYYY.gpkg}.}
}
\description{
Reads Japan administrative boundary data and returns an \code{sf} object.
}
\value{
An \code{sf} data frame.
}
\examples{
\dontrun{
jp_map("prefectures")
jp_map("prefectures", okinawa = FALSE)
jp_map("municipalities", include = "Okinawa")
jp_map("prefecture")
jp_map("municipality", include = "Okinawa")
}
}
