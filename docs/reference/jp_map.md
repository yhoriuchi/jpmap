# Retrieve Japan Map Data

Reads Japan administrative boundary data and returns an `sf` object.

## Usage

``` r
jp_map(
  regions = c("prefectures", "prefecture", "municipalities", "municipality"),
  include = c(),
  exclude = c(),
  data_year = NULL,
  inset = TRUE,
  okinawa = TRUE,
  ogasawara = TRUE,
  territorial_disputes = TRUE,
  data_dir = NULL
)
```

## Arguments

- regions:

  Boundary level: prefectures or municipalities.

- include:

  Regions to include by code, English name, or Japanese name.

- exclude:

  Regions to exclude by code, English name, or Japanese name.

- data_year:

  Boundary data year. The newest appropriate available file is used by
  default. For example, national prefecture maps prefer a national file,
  while one-prefecture municipal requests can use a matching prefecture
  file.

- inset:

  Inset behavior. Use `TRUE` to move both Okinawa and Ogasawara, `FALSE`
  for no movement, or a character vector containing `"okinawa"` and/or
  `"ogasawara"` to move selected island groups.

- okinawa:

  Whether Okinawa should be moved when `inset` includes it.

- ogasawara:

  Whether Ogasawara should be moved when `inset` includes it.

- territorial_disputes:

  Whether to include disputed-territory island/reef shapes. Use `FALSE`
  to exclude them, or a character vector containing one or more of
  `"northern_territories"`, `"okinotorishima"`, `"senkaku"`, and
  `"takeshima"`.

- data_dir:

  Optional directory containing `jpmap_boundaries_YYYY.gpkg`.

## Value

An `sf` data frame.

## Examples

``` r
if (nrow(available_jpmap_data()) > 0) {
  jp_map("prefectures")
  jp_map("prefectures", okinawa = FALSE)
  jp_map("prefectures", territorial_disputes = FALSE)
  jp_map("municipalities", include = "Okinawa")
  jp_map("prefecture")
  jp_map("municipality", include = "Okinawa")
}
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
