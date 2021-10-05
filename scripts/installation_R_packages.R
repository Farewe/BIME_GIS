## R doit avoir été lancé juste avant l'installation
## RIEN ne doit être en mémoire de R (pas d'environnement de travail datant
## d'une session précédente)


setwd("METTRE LE CHEMIN VERS LE DOSSIER CONTENANT LES PACKAGES ICI")



pkgFilenames <- read.csv("pkgFilenames.csv")[, 1]
install.packages(pkgFilenames, repos = NULL, type = "win.binary")
