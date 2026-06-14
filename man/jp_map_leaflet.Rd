\name{jp_map_leaflet}
\alias{jp_map_leaflet}
\title{Draw an Interactive Japan Map with leaflet}
\usage{
jp_map_leaflet(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data = data.frame(),
  values = NULL,
  by = NULL,
  data_year = NULL,
  territorial_disputes = TRUE,
  data_dir = NULL,
  palette = "Blues",
  fill = "grey92",
  color = "grey35",
  weight = 1,
  opacity = 1,
  fill_opacity = 0.75,
  na_color = "#D9D9D9",
  label = NULL,
  popup = NULL,
  tiles = TRUE,
  legend = TRUE,
  fit_bounds = TRUE,
  simplify_tolerance = NULL,
  disputed_fill = NULL,
  disputed_color = NULL,
  disputed_dots = FALSE,
  disputed_dot_radius = 5,
  ...
)
}
\arguments{
\item{regions}{Boundary level: prefectures or municipalities.}
\item{include}{Regions to include by code, English name, or Japanese name.}
\item{exclude}{Regions to exclude by code, English name, or Japanese name.}
\item{data}{Optional data frame to join to the map before drawing.}
\item{values}{Optional column to use for polygon fill colors.}
\item{by}{Optional join column passed to \code{jp_map_join()}.}
\item{data_year}{Boundary data year. The newest appropriate available file is
used by default.}
\item{territorial_disputes}{Whether to include disputed-territory island/reef
shapes. The default is \code{TRUE}. Use \code{FALSE} to exclude them, or a
selected character vector.}
\item{data_dir}{Optional directory containing \code{jpmap_boundaries_YYYY.gpkg}.}
\item{palette}{Palette name or color vector passed to Leaflet palette functions
when \code{values} is supplied.}
\item{fill}{Polygon fill color used when \code{values} is \code{NULL}.}
\item{color}{Polygon outline color.}
\item{weight}{Polygon outline weight.}
\item{opacity}{Polygon outline opacity.}
\item{fill_opacity}{Polygon fill opacity.}
\item{na_color}{Fill color for missing \code{values}.}
\item{label}{\code{NULL} for default region labels, \code{FALSE} for no labels,
a column name, or a character vector with one value per map row.}
\item{popup}{\code{NULL} for default popups, \code{FALSE} for no popups, a
column name, or a character vector with one value per map row.}
\item{tiles}{Whether to add default OpenStreetMap tiles.}
\item{legend}{Whether to add a legend when \code{values} is supplied.}
\item{fit_bounds}{Whether to zoom the widget to the map bounds.}
\item{simplify_tolerance}{Optional tolerance passed to \code{sf::st_simplify()}
before drawing polygons. This is useful for smaller website widgets.}
\item{disputed_fill}{Optional fill color for disputed-territory shapes. The
default, \code{NULL}, draws them quietly with the ordinary map fill.}
\item{disputed_color}{Optional outline color for disputed-territory shapes. The
default, \code{NULL}, draws them quietly with the ordinary map outline.}
\item{disputed_dots}{Whether to draw circle markers on disputed-territory
shapes.}
\item{disputed_dot_radius}{Radius for disputed-territory circle markers.}
\item{...}{Additional arguments passed to \code{leaflet::leaflet()}.}
}
\value{
A \code{leaflet} htmlwidget.
}
\description{
\code{jp_map_leaflet()} creates a simple interactive web map from \code{jpmap}
boundaries. It uses literal longitude/latitude geography because Leaflet web
tiles expect WGS84 coordinates. Use \code{plot_jpmap()} when you want the
static Okinawa and Ogasawara inset layout.
}
\examples{
if (requireNamespace("leaflet", quietly = TRUE) &&
    requireNamespace("dplyr", quietly = TRUE)) {
  data("jp_prefecture_gdp")

  gdp <- jp_prefecture_gdp |>
    dplyr::select(pref_code, prefecture, gdp_per_capita_jpy)

  jp_map_leaflet(
    "prefecture",
    data = gdp,
    values = "gdp_per_capita_jpy",
    popup = "prefecture"
  )
}
}
