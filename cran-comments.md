## Test environments

- Local macOS Tahoe 26.5.1, R 4.6.0

## R CMD check results

0 errors | 0 warnings | 2 notes

This is a new submission. The source tarball is larger than 10 MB because the
package bundles official MLIT N03 2024 municipal boundary data for Okinawa
Prefecture. The bundled file is needed so new users can run the package's
municipality examples immediately without first downloading and converting a
large external boundary archive.

The local check also reports that the installed HTML Tidy is not recent enough
to run HTML validation. This is a local toolchain note.

CRAN incoming checks may flag "GeoPackage", "MLIT", and "Ogasawara" as
possibly misspelled words. These are intended technical/proper terms.

## Downstream dependencies

There are no downstream dependencies because this is a new submission.
