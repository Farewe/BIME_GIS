

# 2.1
# Avec le package rgdal
library(rgdal)
library(raster)
iucn_rg <- readOGR("./data/IUCN data/CAUDATA.shp")
# Résumé de l'objet
iucn_rg

summary(iucn_rg)

plot(iucn_rg)

# Table attributaire
head(iucn_rg)



# Avec le package sf
library(sf)

iucn_sf <- st_read("./data/IUCN data/CAUDATA.shp")
iucn_sf
plot(iucn_sf["family"])
plot(iucn_sf[which(iucn_sf$family == "PLETHODONTIDAE"), 
             "family"])
plot(iucn_sf[which(iucn_sf$family == "SALAMANDRIDAE"), 
             "family"])
plot(iucn_sf[which(iucn_sf$family == "AMBYSTOMATIDAE"), 
             "family"])
plot(iucn_sf[which(iucn_sf$family == "HYNOBIIDAE"), 
             "family"])




# 2.2
continents <- st_read("./data/NaturalEarth data/ne_50m_coastline.shp")

plot(continents[1], col = grey(.5),
     reset = FALSE, graticule = TRUE, axes = TRUE)
plot(iucn_sf[which(iucn_sf$family == "PLETHODONTIDAE"), 
             "family"], add = TRUE)



library(ggplot2)
ggplot() +
  geom_sf(data = continents) +
  geom_sf(data = iucn_sf, aes(fill = family))


# 2.3
library(raster)
jan <- raster("./data/WorldClim data/wc2.0_10m_tavg_01.tif")
jan
plot(jan)

minValue(jan)
maxValue(jan)


worldclim <- stack(paste0("./data/WorldClim data/", 
                          list.files("./data/WorldClim data/")))

MAT <- mean(worldclim)
plot(MAT)

# 3.1 
iucn_sf <- iucn_sf[which(iucn_sf$presence == 1), ]
iucn_sf <- iucn_sf[which(iucn_sf$origin == 1), ]
iucn_sf <- aggregate(iucn_sf, 
                     by = iucn_sf$binomial)
plyr::count(iucn_sf$binomial)
plot(iucn_sf[iucn_sf$binomial == "Pseudoeurycea ruficauda", 1])
# 3.2
MAT <- aggregate(MAT,
                 fact = 6)


plot(MAT)
iucn_sf$binomial <- droplevels(iucn_sf$binomial)
zob <- stack()

for(sp in levels(iucn_sf$binomial))
{
  zob <- addLayer(zob,
                  rasterize(iucn_sf[iucn_sf$binomial == sp, ],
                            MAT, field = 1, fun = function(x, ...) 1))
}

z <- sum(zob, na.rm = T)

a <- rasterize(iucn_sf, 
               MAT,
               field = "binomial",
               fun = "count")


epsg <- make_EPSG()
i <- grep("France", epsg$note, ignore.case=TRUE)
# first three
epsg[i, ]
