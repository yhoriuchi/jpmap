# Boundary Data

`jpmap` stores map boundaries outside the installed package. This keeps
the package small while still allowing detailed prefecture and municipal
maps. The installed package includes lightweight example data: Natural
Earth prefectures for all of Japan and Geoshape municipal boundaries for
Okinawa.

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

Boundary files can be built from Japan’s MLIT National Land Numerical
Information N03 administrative area data.

``` r

jpmap_build_data(year = 2024)
```

The 2024 source archive is about 583 MB, so this command is
intentionally a user-run step.

## Available Data

After building or placing a GeoPackage in the data directory, inspect
available years with:

``` r

available_jpmap_data()
#>   year                                                                    path
#> 1 2021 /private/tmp/jpmap-pkgdown-lib/jpmap/extdata/jpmap_boundaries_2021.gpkg
```

The expected file name pattern is `jpmap_boundaries_YYYY.gpkg`, with
layers named `prefectures` and `municipalities`.
