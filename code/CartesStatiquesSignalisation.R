#!/usr/bin/env Rscript --vanilla

#########################################################################################
# Créer les cartes "statiques - signalisation" pour chacune des étapes                  #
#                                                                                       #
#########################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))

annee <- iti_etape$Details$Date[1] %>% year() %>% as.double()

# Library pour importer Open Street Map et tmap, seulement utile ici
library(rosm)
library(tmap)


# Lecture du shapefile enregistré contenant les parcours et les points
parcours <- st_read(here("gpx/output/parcours.shp"))
points <- st_read(here("gpx/output/points_parcours.shp"))
points_signalisation <- st_read(here("gpx","output","points_signalisation.shp"))

# Modification du CRS pour fonctionnement avec OSM
parcours_stat <- st_transform(parcours, crs = 4326)
points_stat <- st_transform(points, crs = 4326)
signalisation_stat <- st_transform(points_signalisation, crs = 4326)

################################################################################
################################################################################


creation_carte_vignette <- function(pt_sign = "E1_sign_01",
                                    buff = 150)
  {
  
  # Filtrer sur le poi de signalisation d'intérêt
  POI <- signalisation_stat %>% filter(sign_id == pt_sign)

  no_etape <- POI$etape
  

  # Création de la carte carré
  map <- POI %>% 
    st_buffer(dist = buff) %>% 
    st_bbox() %>% 
    osm.raster( crop = TRUE) %>% 
    tm_shape() + tm_rgb() +
    tm_shape(parcours_stat %>% filter(etape == no_etape)) + 
    tm_lines(col = couleurs$bleuTour, 
             lwd= 2)+
    tm_shape(POI)+
    tm_dots(size = 3, 
            col = "red2",
            alpha = 0.9)+
    tm_layout(title = paste("Tour Abitibi ", annee,"\n", pt_sign ), 
              title.size =0.7, 
              title.position = c("left","top"))+
    tm_credits(POI$details, 
               size = 0.5,
               position = c("left","bottom"))+
    tm_compass(type = "arrow", 
               size = 0.9,
               position = c("right", "top"))
  
  tmap_save(tm =map, 
            units = "in",
            height = 4, width = 4,
            filename = here("img", "cartes", "sign", glue('{pt_sign}.png')))
  
} 


#################################################################################
################################################################################

# Boucle sur tous les items de signalisation

lapply(signalisation_stat$sign_id, creation_carte_vignette)

## Processus manuel

# df_temp <- signalisation_stat %>% filter(grepl("^E1", signalisation_stat$sign_id))
# lapply(df_temp$sign_id, creation_carte_vignette)
