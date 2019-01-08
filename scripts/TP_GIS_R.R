

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

MAT <- mean(worldclim, na.rm = T)
plot(MAT)

# 3.1 
iucn_sf <- iucn_sf[which(iucn_sf$presence == 1), ]
iucn_sf <- iucn_sf[which(iucn_sf$origin == 1), ]


plyr::count(iucn_sf$binomial)
plot(iucn_sf[iucn_sf$binomial == "Ambystoma laterale", 2])

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




a <- rasterize(iucn_sf[iucn_sf$binomial == "Ambystoma laterale", ],
          r, 
          field = "binomial", 
          fun = function(x, ...) 1)
b <- rasterize(iucn_sf[iucn_sf$binomial == "Ambystoma laterale", ], 
               r,
               field = "binomial",
               fun = function (x, ...) length(unique(na.omit(x))))



?crop

plot(a[1])
a <- a[-is.na(a[, 1])]

plyr::count(iucn_sf$binomial)[which(plyr::count(iucn_sf$binomial)$freq > 1), ]

plot(MAT)
iucn_sf$binomial <- droplevels(iucn_sf$binomial)

pa.stack <- stack()
for(sp in levels(iucn_sf$binomial))
{
  pa.stack <- addLayer(pa.stack,
                       rasterize(iucn_sf[iucn_sf$binomial == sp, ],
                                 r, 
                                 field = "binomial",
                                 fun = function (x, ...) length(unique(na.omit(x)))))
}
names(pa.stack) <- levels(iucn_sf$binomial)


max(maxValue(pa.stack), na.rm = T)

b <- sum(pa.stack, na.rm = T)
plot(b)

plot(a - b)
zob <- stack()

for(sp in levels(iucn_sf$binomial))
{
  zob <- addLayer(zob,
                  rasterize(iucn_sf[iucn_sf$binomial == sp, ],
                            r, field = "binomial", fun = function(x, ...) 1))
}
names(zob) <- levels(iucn_sf$binomial)

zob2 <- zob
zob2[zob2 > 0] <- 1
plot(zob2[[1:2]])
z <- sum(zob, na.rm = T)

?raster
r <- raster(nrows=180, ncols=360, xmn=-180, xmx=180, ymn=-90, ymx=90, 
            crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0", 
            resolution = 1, vals=NULL)

a <- rasterize(iucn_sf, 
               r,
               field = "binomial",
               fun = function (x, ...) length(unique(na.omit(x))))
plot(a)

epsg <- make_EPSG()
i <- grep("France", epsg$note, ignore.case=TRUE)
# first three
epsg[i, ]
