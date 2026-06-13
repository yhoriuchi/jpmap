# FAQ

## Why move Okinawa and Ogasawara?

Japan spans a long north-south and east-west range. A geographically
literal map can make smaller islands difficult to see. `jpmap` follows
the `usmap` idea of using insets so important regions remain visible in
ordinary plots. Use `inset = FALSE`, `inset = "okinawa"`, or
`inset = "ogasawara"` when you want to exclude one or both transported
island groups.

## Does jpmap include boundary data?

The package includes code for building and reading boundary data, but
large boundary files are kept outside the package. Use
[`jpmap_build_data()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_data.md)
to build a local GeoPackage from MLIT N03 administrative area data.

## Which boundary levels are supported?

The API supports `regions = "prefectures"` and
`regions = "municipalities"`.

## Can I add my own points or lines?

Yes. Use
[`jpmap_transform()`](https://yhoriuchi.github.io/jpmap/reference/jpmap_transform.md)
on a data frame, `sf` object, or `sfc` geometry vector, then add it to a
[`plot_jpmap()`](https://yhoriuchi.github.io/jpmap/reference/plot_jpmap.md)
map with `ggplot2` layers.
