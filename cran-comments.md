## Test environments

- Local macOS Tahoe 26.5.1, R 4.6.0

## R CMD check results

0 errors | 0 warnings | 2 notes

This is a resubmission.

In response to CRAN feedback, relative README links to pkgdown articles have
been replaced with absolute URLs, and the large boundary GeoPackage files have
been removed from jpmap. Boundary data now live outside the functionality
package: users can install the companion jpmapdata package when available or
build local GeoPackage files with jpmap_build_data().

The source tarball is now about 153 KB.

The local check also reports that the installed HTML Tidy is not recent enough
to run HTML validation. This is a local toolchain note.

## Downstream dependencies

There are no downstream dependencies because this is a new submission.
