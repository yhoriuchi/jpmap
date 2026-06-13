# Manage jpmap Boundary Data

Helpers for locating and building the GeoPackage boundary data used by
jpmap. The installed package includes example prefecture boundaries and
Okinawa municipal boundaries. Use `jpmap_build_data()` to build
nationwide detailed municipal boundaries, or
`jpmap_build_data(prefecture = "Ehime")` to build one prefecture from
the official MLIT N03 administrative area data.

## Usage

``` r
jpmap_data_dir(create = TRUE)

available_jpmap_data(data_dir = NULL)

jpmap_build_data(
  year = 2024,
  prefecture = NULL,
  destdir = jpmap_data_dir(),
  url = NULL,
  overwrite = FALSE,
  quiet = FALSE,
  simplify_tolerance = NULL
)
```

## Arguments

- create:

  Whether to create the default data directory.

- data_dir:

  Optional directory to scan for boundary data.

- year:

  Boundary data year.

- prefecture:

  Optional prefecture code, English name, or Japanese name. When
  supplied, only that prefecture's official MLIT N03 file is downloaded
  and built.

- destdir:

  Directory where the generated GeoPackage should be written.

- url:

  Optional source URL. By default, an MLIT N03 URL is constructed.

- overwrite:

  Whether to overwrite an existing GeoPackage.

- quiet:

  Whether to suppress messages from download and spatial reads/writes.

- simplify_tolerance:

  Optional tolerance passed to
  [`sf::st_simplify()`](https://r-spatial.github.io/sf/reference/geos_unary.html).

## Value

`jpmap_data_dir()` returns a path, `available_jpmap_data()` returns a
data frame with `year`, `pref_code`, `prefecture`, and `path`, and
`jpmap_build_data()` invisibly returns the generated file.

## Examples

``` r
if (FALSE) { # \dontrun{
jpmap_build_data(year = 2024)
jpmap_build_data(year = 2024, prefecture = "Ehime")
available_jpmap_data()
} # }
```
