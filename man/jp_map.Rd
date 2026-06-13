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
  data_dir = NULL
)
}
\arguments{
\item{regions}{Boundary level: prefectures or municipalities.}
\item{include}{Regions to include by code, English name, or Japanese name.}
\item{exclude}{Regions to exclude by code, English name, or Japanese name.}
\item{data_year}{Boundary data year. The newest available year is used by default.}
\item{inset}{Whether to move Okinawa and Ogasawara into inset locations.}
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
jp_map("municipalities", include = "Tokyo")
}
}
