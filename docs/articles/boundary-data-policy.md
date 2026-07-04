# Boundary Data Policy

`jpmap` separates functionality from large boundary files. The package
provides the plotting, joining, transformation, and download helpers.
Boundary GeoPackages can come from the companion `jpmapdata` package or
from local files you build from official public sources.

## Boundary Data Locations

`jpmap` checks:

- GeoPackage files installed by the companion `jpmapdata` package;
- GeoPackage files saved in
  [`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md);
- a custom `data_dir` when you pass one.

You can see the available GeoPackage files with:

``` r

library(jpmap)

available <- available_jpmap_data()[c("year", "pref_code", "prefecture", "source")]
row.names(available) <- NULL
available
#>   year pref_code prefecture    source
#> 1 2021      <NA>       <NA> jpmapdata
#> 2 2024        47    Okinawa jpmapdata
```

The website intentionally does not print the user-specific data
directory. Run `jpmap_data_dir(create = FALSE)` locally when you need to
inspect where your own generated boundary files are saved.

## Official Municipal Boundaries

Municipality maps are based on Japan’s MLIT National Land Numerical
Information N03 administrative area data:

- MLIT N03 2024 page:
  <https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-2024.html>
- national 2024 archive:
  <https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2024/N03-20240101_GML.zip>
- Okinawa 2024 archive:
  <https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2024/N03-20240101_47_GML.zip>

Build one prefecture when you only need one prefecture:

``` r

jpmap_build_data(year = 2024, prefecture = "Ehime")
```

Build the national file only when you need all municipalities:

``` r

jpmap_build_data(year = 2024)
```

[`jpmap_build_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
converts the source archive to a GeoPackage with two layers,
`prefectures` and `municipalities`.

## Disputed-Territory Shapes

Disputed-territory shapes are politically sensitive because inclusion
and exclusion are both meaningful map choices. Users can exclude them
explicitly when that is the right display choice:

``` r

plot_jpmap("prefecture", territorial_disputes = FALSE)
```

You can also include selected areas:

``` r

plot_jpmap("prefecture", territorial_disputes = "senkaku")
plot_jpmap("prefecture", territorial_disputes = c("senkaku", "takeshima"))
```

The disputed-territory layer is a cartographic display layer. It is not
a legal statement about sovereignty. The layer exists so users can make
an explicit and documented display choice rather than relying on
inconsistent small-island and reef handling across data sources.

## Reproducibility

For a reproducible project, record:

- the `jpmap` package version;
- the boundary data year;
- whether boundaries came from `jpmapdata`, local files, or a custom
  data directory;
- whether `territorial_disputes` was `FALSE`, `TRUE`, or a selected
  character vector;
- any simplification tolerance used when building local data.

For example:

``` r

sessionInfo()
available <- available_jpmap_data()[c("year", "pref_code", "prefecture", "source")]
row.names(available) <- NULL
available
```
