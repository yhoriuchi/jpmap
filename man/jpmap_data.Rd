\name{jpmap_data}
\alias{jpmap_data_dir}
\alias{available_jpmap_data}
\alias{jpmap_build_data}
\title{Manage jpmap Boundary Data}
\usage{
jpmap_data_dir(create = TRUE)

available_jpmap_data(data_dir = NULL)

jpmap_build_data(
  year = 2024,
  destdir = jpmap_data_dir(),
  url = NULL,
  overwrite = FALSE,
  quiet = FALSE,
  simplify_tolerance = NULL
)
}
\arguments{
\item{create}{Whether to create the default data directory.}
\item{data_dir}{Optional directory to scan for boundary data.}
\item{year}{Boundary data year.}
\item{destdir}{Directory where the generated GeoPackage should be written.}
\item{url}{Optional source URL. By default, an MLIT N03 URL is constructed.}
\item{overwrite}{Whether to overwrite an existing GeoPackage.}
\item{quiet}{Whether to suppress messages from download and spatial reads/writes.}
\item{simplify_tolerance}{Optional tolerance passed to \code{sf::st_simplify()}.}
}
\description{
Helpers for locating and building the GeoPackage boundary data used by jpmap.
}
\value{
\code{jpmap_data_dir()} returns a path, \code{available_jpmap_data()} returns a
data frame, and \code{jpmap_build_data()} invisibly returns the generated file.
}
\examples{
\dontrun{
jpmap_build_data(year = 2024)
available_jpmap_data()
}
}
