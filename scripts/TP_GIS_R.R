

# 2.1
# Avec le package rgdal
library(rgdal)
library(raster)
iucn_rg <- readOGR("./data/IUCN data/CAUDATA.shp")
# Résumé de l'objet
iucn_rg

summary(iucn_rg)
iucn_rg$binomial
length(unique(iucn_rg$binomial))

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
?geom_sf


# 2.3
library(raster)
jan <- raster("./data/WorldClim data/wc2.0_10m_tavg_01.tif")
jan
plot(jan)

minValue(jan)
maxValue(jan)

paste0("./data/Worldclim data/", list.files("./data/WorldClim data/"))



worldclim <- stack(paste0("./data/WorldClim data/", 
                          list.files("./data/WorldClim data/")))

MAT <- mean(worldclim, na.rm = T)
plot(MAT)

# 3.1 
iucn_sf <- iucn_sf[which(iucn_sf$presence == 1), ]
iucn_sf <- iucn_sf[which(iucn_sf$origin == 1), ]
# = la même chose que :
iucn_sf <- iucn_sf[which(iucn_sf$presence == 1 & iucn_sf$origin == 1), ]


# plyr::count(iucn_sf$binomial)
# plot(iucn_sf[iucn_sf$binomial == "Ambystoma laterale", 2])

# 3.2
MAT <- aggregate(MAT,
                 fact = 6)

# 3.3
richness <- rasterize(iucn_sf, 
                      MAT,
                      field = "binomial",
                      fun = function (x, ...) length(unique(na.omit(x))))
plot(richness)

# 3.4
richness.urodeles <- getValues(richness)
temperature <- getValues(MAT)

plot(richness.urodeles ~ temperature,
     cex = .8, pch = 1, col = rgb(0,0,0,alpha=0.3))
abline(v = 27)

# 4
e <- extent(-180, 180, -20, 90)
richness <- crop(richness, 
                 e)


richness.laea <- projectRaster(richness,
                               crs = "+proj=laea +lat_0=90 +lon_0=0",
                               method = "bilinear")

continents.laea <- st_transform(continents, crs = "+proj=laea +lat_0=90 +lon_0=0")

library(tmap)
richness.map <- tm_shape(richness.laea) +
                tm_raster() 

continents.map <- tm_shape(continents.laea) +
                  tm_lines()


richness.map + continents.map 



