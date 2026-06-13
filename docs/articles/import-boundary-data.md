# Import Boundary Data

Use
[`available_jpmap_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
to see which boundary files `jpmap` can find.

``` r

library(jpmap)
available <- available_jpmap_data()
available[c("year", "pref_code", "prefecture")]
#>   year pref_code prefecture
#> 1 2021      <NA>       <NA>
#> 2 2024        47    Okinawa
```

The package checks two locations:

- bundled example files installed with `jpmap`;
- files saved in
  [`jpmap_data_dir()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md),
  unless you pass a custom `data_dir`.

## Load Prefecture Data

[`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md)
returns an `sf` object. Without extra options, prefecture maps use the
bundled all-Japan prefecture file.

``` r

prefectures <- jp_map("prefecture")
prefectures
#> Simple feature collection with 47 features and 4 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -1082217 ymin: -862391 xmax: 1169495 ymax: 898546.7
#> Projected CRS: +proj=laea +lat_0=37.5 +lon_0=137.5 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs
#> First 10 features:
#>    jis_code pref_code prefecture prefecture_ja                           geom
#> 1        01        01   Hokkaido        北海道 MULTIPOLYGON (((510728.9 75...
#> 2        02        02     Aomori        青森県 MULTIPOLYGON (((207443 3278...
#> 3        03        03      Iwate        岩手県 MULTIPOLYGON (((354100.1 33...
#> 4        04        04     Miyagi        宮城県 MULTIPOLYGON (((358110.3 17...
#> 5        05        05      Akita        秋田県 MULTIPOLYGON (((205918 1818...
#> 6        06        06   Yamagata        山形県 MULTIPOLYGON (((178613.3 11...
#> 7        07        07  Fukushima        福島県 MULTIPOLYGON (((301336.6 48...
#> 8        08        08    Ibaraki        茨城県 MULTIPOLYGON (((285086.4 -6...
#> 9        09        09    Tochigi        栃木県 MULTIPOLYGON (((175647.2 -1...
#> 10       10        10      Gunma        群馬県 MULTIPOLYGON (((140563.2 -5...
```

## Load Bundled Okinawa Municipal Data

The package includes official MLIT N03 municipal boundaries for Okinawa
Prefecture as of January 1, 2024.

``` r

okinawa_municipalities <- jp_map("municipality", include = "Okinawa")
okinawa_municipalities
#> Simple feature collection with 5818 features and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -1082857 ymin: 253385.9 xmax: -9296.839 ymax: 753738.1
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
#>    municipality_ja municipality_full_ja                           geom
#> 1       所属未定地           所属未定地 POLYGON ((-440971.4 558329....
#> 2           那覇市               那覇市 POLYGON ((-468564.1 525245....
#> 3           那覇市               那覇市 POLYGON ((-466452.3 532775....
#> 4           那覇市               那覇市 POLYGON ((-468233.3 530636....
#> 5           那覇市               那覇市 POLYGON ((-464920.8 531047....
#> 6           那覇市               那覇市 POLYGON ((-465288.7 531030....
#> 7           那覇市               那覇市 POLYGON ((-464763.5 530959....
#> 8           那覇市               那覇市 POLYGON ((-464632.6 530994....
#> 9         宜野湾市             宜野湾市 POLYGON ((-453576.6 533811....
#> 10          石垣市               石垣市 POLYGON ((-938345.2 334757....
```

This works without `data_year` or `data_dir` because `jpmap` can see the
bundled Okinawa file.

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
