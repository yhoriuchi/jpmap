# Import Boundary Data

Use
[`available_jpmap_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
to see which boundary files `jpmap` can find.

``` r

library(jpmap)
available <- available_jpmap_data()
jpmap_has_boundary_data <- nrow(available) > 0
jpmap_has_okinawa_data <- any(available$year == 2024 & available$pref_code == "47")
available_summary <- available[c("year", "pref_code", "prefecture", "source")]
row.names(available_summary) <- NULL
available_summary
#>   year pref_code prefecture    source
#> 1 2021      <NA>       <NA> jpmapdata
#> 2 2024        47    Okinawa jpmapdata
```

The package checks two locations:

- GeoPackage files installed by the companion `jpmapdata` package;
- files saved in
  [`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md),
  unless you pass a custom `data_dir`.

## Load Prefecture Data

[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md)
returns an `sf` object. Without extra options, prefecture maps use the
first available all-Japan prefecture file.

``` r

prefectures <- jp_map("prefecture")
prefectures
#> Simple feature collection with 51 features and 14 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -1301914 ymin: -1099224 xmax: 1382212 ymax: 952450.3
#> Projected CRS: +proj=laea +lat_0=37.5 +lon_0=137.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs
#> First 10 features:
#>    jis_code pref_code prefecture prefecture_ja is_disputed_territory
#> 1        01        01   Hokkaido        北海道                    NA
#> 2        02        02     Aomori        青森県                    NA
#> 3        03        03      Iwate        岩手県                    NA
#> 4        04        04     Miyagi        宮城県                    NA
#> 5        05        05      Akita        秋田県                    NA
#> 6        06        06   Yamagata        山形県                    NA
#> 7        07        07  Fukushima        福島県                    NA
#> 8        08        08    Ibaraki        茨城県                    NA
#> 9        09        09    Tochigi        栃木県                    NA
#> 10       10        10      Gunma        群馬県                    NA
#>    dispute_region territory territory_ja claimed_pref_code claimed_prefecture
#> 1            <NA>      <NA>         <NA>              <NA>               <NA>
#> 2            <NA>      <NA>         <NA>              <NA>               <NA>
#> 3            <NA>      <NA>         <NA>              <NA>               <NA>
#> 4            <NA>      <NA>         <NA>              <NA>               <NA>
#> 5            <NA>      <NA>         <NA>              <NA>               <NA>
#> 6            <NA>      <NA>         <NA>              <NA>               <NA>
#> 7            <NA>      <NA>         <NA>              <NA>               <NA>
#> 8            <NA>      <NA>         <NA>              <NA>               <NA>
#> 9            <NA>      <NA>         <NA>              <NA>               <NA>
#> 10           <NA>      <NA>         <NA>              <NA>               <NA>
#>    claimed_prefecture_ja source source_url note                           geom
#> 1                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((511996.2 75...
#> 2                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((207443 3278...
#> 3                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((354100.1 33...
#> 4                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((358110.3 17...
#> 5                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((205918 1818...
#> 6                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((178613.3 11...
#> 7                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((301336.6 48...
#> 8                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((285086.4 -6...
#> 9                   <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((175647.2 -1...
#> 10                  <NA>   <NA>       <NA> <NA> MULTIPOLYGON (((140563.2 -5...
```

## Load Okinawa Municipal Data

The companion data package can provide official MLIT N03 municipal
boundaries for Okinawa Prefecture as of January 1, 2024.

``` r

okinawa_municipalities <- jp_map("municipality", include = "Okinawa")
okinawa_municipalities
#> Simple feature collection with 5722 features and 21 fields
#> Geometry type: GEOMETRY
#> Dimension:     XY
#> Bounding box:  xmin: -1302554 ymin: 381372.8 xmax: -228994.3 ymax: 881725
#> Projected CRS: +proj=laea +lat_0=37.5 +lon_0=137.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs
#> First 10 features:
#>    jis_code pref_code prefecture prefecture_ja municipality_code
#> 1     47000        47    Okinawa        沖縄県             47000
#> 2     47201        47    Okinawa        沖縄県             47201
#> 3     47201        47    Okinawa        沖縄県             47201
#> 4     47201        47    Okinawa        沖縄県             47201
#> 5     47201        47    Okinawa        沖縄県             47201
#> 6     47201        47    Okinawa        沖縄県             47201
#> 7     47201        47    Okinawa        沖縄県             47201
#> 8     47201        47    Okinawa        沖縄県             47201
#> 9     47205        47    Okinawa        沖縄県             47205
#> 10    47207        47    Okinawa        沖縄県             47207
#>    municipality_ja municipality_full_ja is_disputed_territory dispute_region
#> 1       所属未定地           所属未定地                    NA           <NA>
#> 2           那覇市               那覇市                    NA           <NA>
#> 3           那覇市               那覇市                    NA           <NA>
#> 4           那覇市               那覇市                    NA           <NA>
#> 5           那覇市               那覇市                    NA           <NA>
#> 6           那覇市               那覇市                    NA           <NA>
#> 7           那覇市               那覇市                    NA           <NA>
#> 8           那覇市               那覇市                    NA           <NA>
#> 9         宜野湾市             宜野湾市                    NA           <NA>
#> 10          石垣市               石垣市                    NA           <NA>
#>    territory territory_ja claimed_pref_code claimed_prefecture
#> 1       <NA>         <NA>              <NA>               <NA>
#> 2       <NA>         <NA>              <NA>               <NA>
#> 3       <NA>         <NA>              <NA>               <NA>
#> 4       <NA>         <NA>              <NA>               <NA>
#> 5       <NA>         <NA>              <NA>               <NA>
#> 6       <NA>         <NA>              <NA>               <NA>
#> 7       <NA>         <NA>              <NA>               <NA>
#> 8       <NA>         <NA>              <NA>               <NA>
#> 9       <NA>         <NA>              <NA>               <NA>
#> 10      <NA>         <NA>              <NA>               <NA>
#>    claimed_prefecture_ja source source_url note municipality
#> 1                   <NA>   <NA>       <NA> <NA>         <NA>
#> 2                   <NA>   <NA>       <NA> <NA>         <NA>
#> 3                   <NA>   <NA>       <NA> <NA>         <NA>
#> 4                   <NA>   <NA>       <NA> <NA>         <NA>
#> 5                   <NA>   <NA>       <NA> <NA>         <NA>
#> 6                   <NA>   <NA>       <NA> <NA>         <NA>
#> 7                   <NA>   <NA>       <NA> <NA>         <NA>
#> 8                   <NA>   <NA>       <NA> <NA>         <NA>
#> 9                   <NA>   <NA>       <NA> <NA>         <NA>
#> 10                  <NA>   <NA>       <NA> <NA>         <NA>
#>    claimed_municipality_code claimed_municipality claimed_municipality_ja
#> 1                       <NA>                 <NA>                    <NA>
#> 2                       <NA>                 <NA>                    <NA>
#> 3                       <NA>                 <NA>                    <NA>
#> 4                       <NA>                 <NA>                    <NA>
#> 5                       <NA>                 <NA>                    <NA>
#> 6                       <NA>                 <NA>                    <NA>
#> 7                       <NA>                 <NA>                    <NA>
#> 8                       <NA>                 <NA>                    <NA>
#> 9                       <NA>                 <NA>                    <NA>
#> 10                      <NA>                 <NA>                    <NA>
#>                              geom
#> 1  POLYGON ((-660668.8 686316....
#> 2  POLYGON ((-688261.6 653232....
#> 3  POLYGON ((-686149.7 660762,...
#> 4  POLYGON ((-687930.7 658623....
#> 5  POLYGON ((-684618.2 659034....
#> 6  POLYGON ((-684986.2 659017....
#> 7  POLYGON ((-684460.9 658946....
#> 8  POLYGON ((-684330.1 658981....
#> 9  POLYGON ((-673274 661798.1,...
#> 10 POLYGON ((-1158043 462743.9...
```

This works without `data_year` or `data_dir` when `jpmap` can see the
Okinawa file through `jpmapdata` or
[`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md).

## Load Locally Built Municipal Data

After building a local file, use the same `include` value to select the
prefecture.

``` r

jpmap_build_data(year = 2024, prefecture = "Ehime")
ehime_municipalities <- jp_map("municipality", include = "Ehime", data_year = 2024)
```

If you saved the file somewhere else, pass that folder as `data_dir`.

``` r

ehime_municipalities <- jp_map(
  "municipality",
  include = "Ehime",
  data_year = 2024,
  data_dir = "jpmap-data"
)
```

## Inspect A GeoPackage

The GeoPackage layers are ordinary spatial data layers, so you can
inspect them with `sf`.

``` r

okinawa_file <- available$path[available$year == 2024 & available$pref_code == "47"]

sf::st_layers(okinawa_file)
#> Driver: GPKG 
#> Available layers:
#>       layer_name geometry_type features fields crs_name
#> 1    prefectures Multi Polygon        1      4   WGS 84
#> 2 municipalities       Polygon     5818      7   WGS 84
```

Read a layer directly only when you need lower-level control. Most map
workflows can use
[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md)
instead.

``` r

municipalities <- sf::st_read(okinawa_file, layer = "municipalities")
```

## File Names

`jpmap` recognizes these file names:

- `jpmap_boundaries_YYYY.gpkg` for national data;
- `jpmap_boundaries_YYYY_PP.gpkg` for one-prefecture data.

The `PP` suffix is the two-digit prefecture code, such as `38` for Ehime
and `47` for Okinawa.
