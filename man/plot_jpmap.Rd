\name{plot_jpmap}
\alias{plot_jpmap}
\title{Plot a Japan Map}
\usage{
plot_jpmap(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data = data.frame(),
  values = NULL,
  labels = FALSE,
  label_color = "black",
  data_year = NULL,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE,
  inset_boxes = TRUE,
  inset_box_color = "grey45",
  inset_box_linewidth = 0.25,
  data_dir = NULL,
  color = "white",
  linewidth = 0.2,
  ...
)
}
\arguments{
\item{regions}{Boundary level: prefectures or municipalities.}
\item{include}{Regions to include by code, English name, or Japanese name.}
\item{exclude}{Regions to exclude by code, English name, or Japanese name.}
\item{data}{Optional data frame to join to the map.}
\item{values}{Column name in \code{data} to use as the fill variable.}
\item{labels}{Whether to draw region labels.}
\item{label_color}{Label text color.}
\item{data_year}{Boundary data year.}
\item{inset}{Inset behavior. Use \code{TRUE} to move both Okinawa and
Ogasawara, \code{FALSE} for no movement, or a character vector containing
\code{"okinawa"} and/or \code{"ogasawara"} to move selected island groups.}
\item{okinawa}{Whether Okinawa should be moved when \code{inset} includes it.}
\item{ogasawara}{Whether Ogasawara should be moved when \code{inset} includes it.}
\item{inset_boxes}{Whether to draw boxes around transported Okinawa and
Ogasawara insets.}
\item{inset_box_color}{Outline color for inset boxes.}
\item{inset_box_linewidth}{Line width for inset boxes.}
\item{data_dir}{Optional directory containing \code{jpmap_boundaries_YYYY.gpkg}.}
\item{color}{Boundary line color.}
\item{linewidth}{Boundary line width.}
\item{...}{Additional arguments passed to \code{ggplot2::geom_sf()}.}
}
\description{
Plots Japan prefecture or municipal boundaries using \code{ggplot2}.
}
\value{
A \code{ggplot2} plot.
}
\examples{
\dontrun{
plot_jpmap("prefecture")
plot_jpmap("prefecture", ogasawara = FALSE)
plot_jpmap("prefecture", inset_boxes = FALSE)
plot_jpmap("municipality", include = "Okinawa")
}
}
