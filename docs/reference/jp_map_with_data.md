# Join Data to a jpmap Map

Joins user data to a Japan map object.

## Usage

``` r
jp_map_with_data(map, data, values = NULL, by = NULL)
```

## Arguments

- map:

  An `sf` object returned by
  [`jp_map()`](https://yhoriuchi.github.io/jpmap/reference/jp_map.md).

- data:

  A data frame containing a matching administrative code or name column.

- values:

  Optional value column to check after joining.

- by:

  Optional join column. If omitted, jpmap guesses from common columns.

## Value

An `sf` object.
