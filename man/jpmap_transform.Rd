\name{jpmap_transform}
\alias{jpmap_transform}
\title{Transform Data to the jpmap Projection}
\usage{
jpmap_transform(data, input_names = c("lon", "lat"), output_names = input_names, inset = TRUE)
}
\arguments{
\item{data}{An \code{sf} object, \code{sfc} geometry vector, or data frame.}
\item{input_names}{Longitude and latitude column names for data frames.}
\item{output_names}{Output coordinate column names for data frames.}
\item{inset}{Whether to move Okinawa and Ogasawara into inset locations.}
}
\description{
Transforms geographic data to the jpmap projected coordinate system. When
\code{inset = TRUE}, Okinawa and Ogasawara are moved to visible inset locations.
}
\value{
An object of the same general type as \code{data}.
}
\examples{
places <- data.frame(
  lon = c(139.767, 127.681, 142.191),
  lat = c(35.681, 26.212, 27.094)
)
jpmap_transform(places, output_names = c("x", "y"))
}
