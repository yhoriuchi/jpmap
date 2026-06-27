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

Manual examples have also been reworked so quick local examples run normally,
while map-building examples that can take more than 5 seconds when boundary
data are installed use `\donttest{}`. The example that builds boundary data
from an external MLIT download also uses `\donttest{}` and writes to
`tempdir()`.

Vignette map chunks now run only for pkgdown builds or when
`JPMAP_FULL_VIGNETTES=true`, so a CRAN source package built on a machine with
the companion data package installed does not embed large map or leaflet
outputs.

The package version has been bumped to 0.1.2 for this resubmission.

The source tarball is now about 154 KB.

The local check also reports that the installed HTML Tidy is not recent enough
to run HTML validation. This is a local toolchain note.

## Downstream dependencies

There are no downstream dependencies because this is a new submission.
