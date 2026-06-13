\name{jp_map_with_data}
\alias{jp_map_with_data}
\title{Join Data to a jpmap Map}
\usage{
jp_map_with_data(map, data, values = NULL, by = NULL)
}
\arguments{
\item{map}{An \code{sf} object returned by \code{jp_map()}.}
\item{data}{A data frame containing a matching administrative code or name column.}
\item{values}{Optional value column to check after joining.}
\item{by}{Optional join column. If omitted, jpmap guesses from common columns.}
}
\description{
Joins user data to a Japan map object.
}
\value{
An \code{sf} object.
}
