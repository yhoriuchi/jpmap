# Selected U.S. military installations in Japan

A sample data frame containing selected U.S. military installations in
Japan with longitude/latitude coordinates and public approximate
personnel figures where those figures have a clear source.

## Format

A data frame with 17 rows and 12 variables:

- base:

  Installation or command name.

- branch:

  Primary U.S. military branch.

- prefecture:

  Japanese prefecture.

- municipality:

  Municipality or municipalities.

- lon:

  Longitude in WGS84.

- lat:

  Latitude in WGS84.

- personnel:

  Approximate public personnel figure, when available.

- personnel_scope:

  What the public figure counts.

- personnel_geography:

  Whether the figure describes an installation, regional total, command,
  or broader installation community.

- personnel_is_base_specific:

  Whether `personnel` is interpreted as a base-specific figure.

- source_url:

  Source URL.

- note:

  Caveat for use in examples.

## Details

These values are intended for examples and are not an official personnel
accounting. Some rows describe broader installation, regional, command,
or community populations; see `personnel_scope` and
`personnel_geography`.
