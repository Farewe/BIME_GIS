getDependencies <- function(packs){
  dependencyNames <- unlist(
    tools::package_dependencies(packages = packs, db = available.packages(),
                                which = c("Depends", "Imports"),
                                recursive = TRUE))
  packageNames <- union(packs, dependencyNames)
  packageNames
}
# Calculate dependencies
packages <- getDependencies(c("dplyr", "rgdal", "raster", "sf", "rgeos",
                              "ggplot2", "tmap"))

setwd("d:/Rpackages")
pkgInfo <- download.packages(pkgs = packages, destdir = "d:/Rpackages", type = "win.binary")
write.csv(file = "pkgFilenames.csv", basename(pkgInfo[, 2]), row.names = FALSE)
