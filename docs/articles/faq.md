# FAQ

## Why move Okinawa and Ogasawara?

Japan spans a long north-south and east-west range. A geographically
literal map can make smaller islands difficult to see. `jpmap` follows
the `usmap` idea of using insets so important regions remain visible in
ordinary plots. Use `inset = FALSE`, `inset = "okinawa"`, or
`inset = "ogasawara"` when you want to exclude one or both transported
island groups. You can also use `okinawa = FALSE` or
`ogasawara = FALSE`, mirroring the style of `UchidaMizuki/jpmap`.
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
draws inset boxes by default; set `inset_boxes = FALSE` to remove them.
The boxes are visual guide frames for the transported inset clusters,
not legal extents for every remote island in every source layer.

## Does jpmap include boundary data?

The package includes all-prefecture example boundaries and official MLIT
N03 municipal boundaries for Okinawa Prefecture as of January 1, 2024.
Large nationwide municipal files are kept outside the package. Use
[`jpmap_build_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
to build a local GeoPackage from MLIT N03 administrative area data. Use
`jpmap_build_data(prefecture = "Ehime")` when you only need one
prefecture.

## Which boundary levels are supported?

The API supports `regions = "prefectures"` and
`regions = "municipalities"`.

## Can I add my own points or lines?

Yes. Use
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
on a data frame, `sf` object, or `sfc` geometry vector, then add it to a
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
map with `ggplot2` layers.
