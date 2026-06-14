\name{jpmap_transform}
\alias{jpmap_transform}
\title{Transform Data to the jpmap Projection}
\usage{
jpmap_transform(
  data,
  input_names = c("lon", "lat"),
  output_names = input_names,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE
)
}
\arguments{
\item{data}{An \code{sf} object, \code{sfc} geometry vector, or data frame.}
\item{input_names}{Longitude and latitude column names for data frames.}
\item{output_names}{Output coordinate column names for data frames.}
\item{inset}{Inset behavior. Use \code{TRUE} to move both Okinawa and
Ogasawara, \code{FALSE} for no movement, or a character vector containing
\code{"okinawa"} and/or \code{"ogasawara"} to move selected island groups.}
\item{okinawa}{Whether Okinawa should be moved when \code{inset} includes it.}
\item{ogasawara}{Whether Ogasawara should be moved when \code{inset} includes it.}
}
\description{
Transforms geographic data to the jpmap projected coordinate system. When
\code{inset = TRUE}, Okinawa and Ogasawara are moved to visible inset
locations. Use \code{okinawa = FALSE}, \code{ogasawara = FALSE},
\code{inset = "okinawa"}, or \code{inset = "ogasawara"} to transport only one
island group.
}
\value{
An object of the same general type as \code{data}.
}
\examples{
if (requireNamespace("tibble", quietly = TRUE)) {
  places <- tibble::tribble(
    ~place, ~lon, ~lat,
    "Tokyo", 139.767, 35.681,
    "Naha", 127.681, 26.212,
    "Ogasawara", 142.191, 27.094
  )

  places |>
    jpmap_transform(output_names = c("x", "y"))
  places |>
    jpmap_transform(output_names = c("x", "y"), inset = "okinawa")
  places |>
    jpmap_transform(output_names = c("x", "y"), ogasawara = FALSE)
}
}
