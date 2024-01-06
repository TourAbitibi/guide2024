#!/usr/bin/env Rscript --vanilla

#########################################################################################
# Créer le raster avec les données d'élévation et sauvegarder vers .tif                 #
# Opération manuelle à faire seulement si les parcours sortent de la région habituelle  #
#                                                                                       #
# Input : Shapefile contenant les gpx des parcours - "gpx/output/parcours.shp"          #
# Output : le Raster de la région complète "rasterElevation/elv_parcours.tif"           #
#                                                                                       #
#########################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","_LibsVars.R"))


# Shapefile incluant tous les parcours
parcours <- st_read(here("gpx/output/parcours.shp"))


ui_todo("Télécharger les {ui_field('élévations')} dans la zone couvrant les parcours.")
ui_warn("Long à télécharger")

elv_parcours <- get_elev_raster(parcours,
                                z=12,
                               neg_to_na = TRUE)

ui_done("{ui_field('Élévations')} téléchargées.")


# Sauvegarde du fichier tif 
elv_parcours %>%
  writeRaster(here("rasterElevation/elv_parcours.tif"),
             overwrite=TRUE)

ui_done("{ui_field('Élévations')} sauvegardées vers {ui_field('rasterElevation/elv_parcours.tif')}")

################################################################################

## --> Pas possible car Snakemake efface l'output avant le rouler.. 

# Vérifier si les fichiers ont changés avant de faire la sauvegarde
# car création de longues opérations dans le Snakefile
# (création .csv à la prochaine étape)

## Vérifier si le parcours.tif existe

# assignation initiale d'un raster
# tif_en_memoire = raster(nrows=8, ncols=8, xmn = 1, xmx = 5, ymn = 1, ymx = 5, vals = 1:64) 
# 
# if (file.exists(here("rasterElevation","elv_parcours.tif"))) { tif_en_memoire = raster(here("rasterElevation/elv_parcours.tif"))}     
# 
# ## Vérifier si les 2 parcours ont exactement le même extent :
# meme_extent <- (extent(elv_parcours) == extent(tif_en_memoire))
# 
# ifelse(meme_extent,
#        # Même extent = pas de changement
#        "Pas besoin d'écrire `elv_parcours.tif` à nouveau : aucun changement",
#        # Sinon, sauvegarde du raster vers un fichier .tif
#        # Attention : longue opération
#        elv_parcours %>% 
#          writeRaster(here("rasterElevation/elv_parcours.tif"),
#                      overwrite=TRUE)
#        )
# 

################################################################################

# Lecture du fichier enregistré
# elv_parcours <- raster(here("rasterElevation/elv_parcours.tif"))

# Visualisation du profil d'élévation
# elev_map <- mapview(elv_parcours, 
#         layer.name = "Elevation",
#         col.region = hcl.colors(50, palette = "Earth"),
#         maxpixels = 1e6)
# 
# elev_map@map
