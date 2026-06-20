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
  territorial_disputes = TRUE,
  disputed_fill = NULL,
  disputed_color = NULL,
  disputed_linewidth = NULL,
  disputed_dots = FALSE,
  disputed_dot_fill = "#001040",
  disputed_dot_color = "white",
  disputed_dot_size = 1.25,
  disputed_dot_stroke = 0.2,
  inset_boxes = TRUE,
  inset_box_color = "grey50",
  inset_box_linewidth = 0.35,
  data_dir = NULL,
  xlim = NULL,
  ylim = NULL,
  x_breaks = ggplot2::waiver(),
  y_breaks = ggplot2::waiver(),
  x_labels = ggplot2::waiver(),
  y_labels = ggplot2::waiver(),
  fill = "grey92",
  color = "grey35",
  linewidth = 0.25,
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
\code{"okinawa"} and/or \code{"ogasawara"} to move selected island groups. For
filtered municipality maps such as
\code{plot_jpmap("municipality", include = "Okinawa")}, the default plot frame
is local and non-inset unless \code{inset} is supplied explicitly.}
\item{okinawa}{Whether Okinawa should be moved when \code{inset} includes it.}
\item{ogasawara}{Whether Ogasawara should be moved when \code{inset} includes it.}
\item{territorial_disputes}{Whether to include disputed-territory island/reef
shapes. Use \code{FALSE} to exclude them, or a character vector containing one
or more of \code{"northern_territories"}, \code{"okinotorishima"},
\code{"senkaku"}, and \code{"takeshima"}.}
\item{disputed_fill}{Optional fill color for disputed-territory shapes. When
\code{NULL}, the ordinary map fill is used.}
\item{disputed_color}{Optional outline color for disputed-territory shapes. When
\code{NULL}, the ordinary map outline is used.}
\item{disputed_linewidth}{Optional line width for disputed-territory shapes.}
\item{disputed_dots}{Whether to draw dot markers on disputed-territory shapes.}
\item{disputed_dot_fill}{Fill color for disputed-territory dot markers.}
\item{disputed_dot_color}{Outline color for disputed-territory dot markers.}
\item{disputed_dot_size}{Size for disputed-territory dot markers.}
\item{disputed_dot_stroke}{Stroke width for disputed-territory dot markers.}
\item{inset_boxes}{Whether to draw boxes around transported Okinawa and
Ogasawara insets.}
\item{inset_box_color}{Outline color for inset boxes.}
\item{inset_box_linewidth}{Line width for inset boxes.}
\item{data_dir}{Optional directory containing \code{jpmap_boundaries_YYYY.gpkg}.}
\item{xlim, ylim}{Optional longitude and latitude limits for the plot frame.}
\item{x_breaks, y_breaks}{Optional longitude and latitude axis breaks.}
\item{x_labels, y_labels}{Optional longitude and latitude axis labels.}
\item{fill}{Boundary fill color when \code{values} is not supplied.}
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
\donttest{
if (nrow(available_jpmap_data()) > 0) {
  plot_jpmap("prefecture")
  plot_jpmap("prefecture", ogasawara = FALSE)
  plot_jpmap("prefecture", territorial_disputes = FALSE)
  plot_jpmap(
    "prefecture",
    ogasawara = FALSE,
    xlim = c(122, 149),
    ylim = c(28.5, 47),
    x_breaks = seq(125, 145, 5),
    y_breaks = seq(30, 45, 5)
  )
  plot_jpmap("prefecture", inset_boxes = FALSE)
  plot_jpmap("municipality", include = "Okinawa")
}
}
}
