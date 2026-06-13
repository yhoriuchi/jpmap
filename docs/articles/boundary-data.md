# Boundary Data

`jpmap` can work with detailed administrative boundaries, but nationwide
municipal polygons are large. The installed package therefore includes
lightweight example data: Natural Earth prefectures for all of Japan and
Geoshape municipal boundaries for Okinawa.

## Data Directory

Use
[`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
to find the default local data directory.

``` r

library(jpmap)
jpmap_data_dir(create = FALSE)
#> [1] "/Users/yh25m/Library/Application Support/org.R-project.R/R/jpmap"
```

## Building Data

Boundary files can be built from Japan’s official MLIT National Land
Numerical Information N03 administrative area data. The national 2024
source archive is about 583 MB, so a full national build is an explicit
user-run step.

``` r

jpmap_build_data(year = 2024)
```

When you only need one prefecture, build a smaller prefecture-specific
file from the same official source.

``` r

jpmap_build_data(year = 2024, prefecture = "Ehime")
jpmap_build_data(year = 2024, prefecture = "沖縄県")
```

## jpndistrict

If you already use `jpndistrict`, its `sf` output can be transformed
into the same coordinate system used by `jpmap`. `jpndistrict` is not a
hard dependency because it is not currently available from CRAN, but it
is a useful companion for workflows that already use it.

``` r

library(jpndistrict)

ehime <- jpn_cities(38)
ehime_jpmap <- jpmap_transform(ehime, inset = FALSE)
```

## Available Data

After building or placing a GeoPackage in the data directory, inspect
available years with:

``` r

available_jpmap_data()
#>   year pref_code prefecture
#> 1 2021      <NA>       <NA>
#>                                                                      path
#> 1 /private/tmp/jpmap-pkgdown-lib/jpmap/extdata/jpmap_boundaries_2021.gpkg
```

The expected file name patterns are `jpmap_boundaries_YYYY.gpkg` for
national data and `jpmap_boundaries_YYYY_PP.gpkg` for one-prefecture
data, with layers named `prefectures` and `municipalities`.
