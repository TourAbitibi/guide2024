#!/usr/bin/env Rscript --vanilla

#########################################################################################
# Créer les cartes "statiques" pour chacune des étapes                                  #
#                                                                                       #
# Input : Shapefile contenant les gpx des parcours - "gpx/output/parcours.shp"          #
# Output : 3 fichiers png par étape : 1 vue d'ensemble, 1 détailts départ et 1 arrivée  #
#                                                                                       #
#########################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))

# Library pour importer Open Street Map et tmap, seulement utile ici
library(rosm)
library(tmap)


# Lecture du shapefile enregistré contenant les parcours et les points
parcours <- st_read(here("gpx/output/parcours.shp"))
points <- st_read(here("gpx/output/points_parcours.shp"))

# Modification du CRS pour fonctionnement avec OSM
parcours_stat <- st_transform(parcours, crs = 4326)
points_stat <- st_transform(points, crs = 4326)
################################################################################
################################################################################

# Filtrer la ligne d'une étape

creation_3_map <- function(no_etape,
                           pct_point_debut = 0.02, 
                           pct_point_fin = 0.97,
                           pos_h_arrow = "left",
                           pos_v_arrow = "top",
                           pos_h_scale = "left",
                           pos_v_scale = "bottom",
                           buff = 100,
                           scale = 25){

  # Filtrer sur l'étape à créer
  etape_line <- parcours_stat %>% filter(etape == no_etape)
  
  # Filtrer sur l'étape à créer et joindre à df_POI 
  POI <- points_stat %>% filter(etape == no_etape)
  
  # Transformer le trajet en points
  etape_points <- st_as_sf(st_cast(st_geometry(etape_line), to = "POINT")) 
  
  # Points départ et arrivée
  pt_depart <- etape_points %>% head(n=1)
  pt_arrivee <- etape_points %>% tail(n=1)
  
  
  # Carte complète
  map <- etape_line %>% 
    st_buffer(dist = buff) %>% 
    st_bbox() %>% 
    osm.raster( crop = TRUE) %>% 
  tm_shape() + tm_rgb() +
    tm_shape(etape_line) + 
    tm_lines(col = couleurs$bleuTour, 
             lwd= 2) +
    tm_scale_bar(breaks = c(0,scale/5,scale/5*2,scale),
                 text.size = 0.8, 
                 position=c(pos_h_scale,pos_v_scale)) +
    # ajout d'une rose des vents
    tm_compass(type = "arrow", 
               position = c(pos_h_arrow, pos_v_arrow)) +
    # Ajout point de départ réel, KOM, Bonus, Maire
    
    tm_shape(POI)+
    tm_symbols(size = 0.8, 
               shape = 21,
               col = "color")+
    tm_text(text = "labels",
            size = 0.7,
            ymod =0.8,
            col = couleurs$bleuTour)+
    
    # Ajout point arrivée
    tm_shape(pt_arrivee)+
    tm_symbols(size = 0.8, 
               shape = 23,
               col = couleurs$rougeDanger)
  
  tmap_save(tm =map, filename = here("img", "cartes", "input", glue('Etape{no_etape}_Full.png')))
  
  # Carte Départ
  map <- st_cast(st_combine(etape_points[ 1: nrow(etape_points)*pct_point_debut , ]), "LINESTRING") %>% 
  st_buffer(dist = 100) %>% 
    st_bbox() %>% 
    osm.raster( crop = TRUE) %>% 
    tm_shape(.) + 
      tm_rgb() +
      tm_shape(etape_line) + 
      tm_lines(col = couleurs$bleuTour, 
               lwd= 4)+
    # Ajout pt départ
    tm_shape(pt_depart)+
    tm_symbols(size = 0.8, 
               shape = 21,
               col = couleurs$depart)
  
  tmap_save(tm =map, filename = here("img", "cartes", "input", glue('Etape{no_etape}_Dep.png')))
  
  
  # Carte Arrivée
  map <- st_cast(st_combine(etape_points[ (floor(nrow(etape_points))*pct_point_fin) : nrow(etape_points) , ]), "LINESTRING") %>% 
    st_buffer(dist = 100) %>% 
    st_bbox() %>% 
    osm.raster( crop = TRUE) %>% 
    tm_shape(.) + 
    tm_rgb() +
    tm_shape(etape_line) + 
    tm_lines(col = couleurs$bleuTour, 
             lwd= 4)+
    # Ajout pt arrivée
    tm_shape(pt_arrivee)+
    tm_symbols(size = 0.8, 
               shape = 23,
               col = couleurs$rougeDanger)
  
  tmap_save(tm =map, 
            filename = here("img", "cartes", "input", glue('Etape{no_etape}_Arr.png')))
  
}  

#################################################################################

# Création des cartes par étapes, avec paramètres spécifiques

creation_3_map(no_etape =1,
               pct_point_debut = 0.01, 
               pct_point_fin = 0.91,
               pos_h_arrow = "right",
               pos_v_arrow = "top",
               pos_h_scale = "left",
               pos_v_scale = "bottom",
               buff = 300)

creation_3_map(no_etape =2,
               pct_point_debut = 0.02, 
               pct_point_fin = 0.98,
               pos_h_arrow = "left",
               pos_v_arrow = "top",
               pos_h_scale = "right",
               pos_v_scale = "bottom",
               buff = 300)


# CLMI, voir à la fin du fichier


creation_3_map(no_etape =4,
               pct_point_debut = 0.032, 
               pct_point_fin = 0.97,
               pos_h_arrow = "right",
               pos_v_arrow = "top",
               pos_h_scale = "left",
               pos_v_scale = "bottom",
               buff = 300)


creation_3_map(no_etape =5,
               pct_point_debut = 0.044, 
               pct_point_fin = 0.970,
               pos_h_arrow = "right",
               pos_v_arrow = "bottom",
               pos_h_scale = "left",
               pos_v_scale = "top")


creation_3_map(no_etape =6,
               pct_point_debut = 0.048,
               pct_point_fin = 0.92,
               pos_h_arrow = "right",
               pos_v_arrow = "bottom",
               pos_h_scale = "left",
               pos_v_scale = "bottom",
               buff = 100,
               scale = 2.5)


creation_3_map(no_etape =7,
               pct_point_debut = 0.012, 
               pct_point_fin = 0.97,
               pos_h_arrow = "right",
               pos_v_arrow = "top",
               pos_h_scale = "left",
               pos_v_scale = "bottom",
               buff = 300)
 
################################################################################

# Besoins particuliers pour le CLMI, à faire manuellement


no_etape = 3
pct_point_debut = 0.04
pct_point_fin = 0.96
pos_h_arrow = "left"
pos_v_arrow = "top"
pos_h_scale = "left"
pos_v_scale = "bottom"
buff = 100

# Filtrer sur l'étape à créer
etape_line <- parcours_stat %>% filter(etape == no_etape)

# Transformer le trajet en points
etape_points <- st_as_sf(st_cast(st_geometry(etape_line), to = "POINT")) 

# Points départ et arrivée
pt_depart <- etape_points %>% head(n=1)
pt_arrivee <- etape_points %>% tail(n=1)

# Carte complète
map <- etape_line %>% 
  st_buffer(dist = buff) %>% 
  st_bbox() %>% 
  osm.raster( crop = TRUE) %>% 
  tm_shape() + tm_rgb() +
  tm_shape(etape_line) + 
  tm_lines(col = couleurs$bleuTour, 
           lwd= 2) +
  # ajout d'une rose des vents
  tm_compass(type = "arrow", 
             position = c(pos_h_arrow, pos_v_arrow)) +
  # Ajout point de départ (vert) et arrivée (rouge)
  tm_shape(pt_depart)+
  tm_symbols(size = 0.8, 
             shape = 21,
             col = couleurs$depart)+
  tm_shape(pt_arrivee)+
  tm_symbols(size = 0.8, 
             shape = 23,
             col = couleurs$rougeDanger)

tmap_save(tm =map, filename = here("img", "cartes", "input", glue('Etape{no_etape}_Full.png')))

# Carte Départ
map <- st_cast(st_combine(etape_points[ 1: nrow(etape_points)*pct_point_debut , ]), "LINESTRING") %>% 
  st_buffer(dist = 150) %>% 
  st_bbox() %>% 
  osm.raster( crop = TRUE) %>% 
  tm_shape(.) + 
  tm_rgb() +
  tm_shape(etape_line) + 
  tm_lines(col = couleurs$bleuTour, 
           lwd= 4)+
  # Ajout pt départ
  tm_shape(pt_depart)+
  tm_symbols(size = 0.8, 
             shape = 21,
             col = couleurs$depart)

tmap_save(tm =map, filename = here("img", "cartes", "input", glue('Etape{no_etape}_Dep.png')))


# Carte Arrivée
map <- st_cast(st_combine(etape_points[ (floor(nrow(etape_points))*pct_point_fin) : nrow(etape_points) , ]), "LINESTRING") %>% 
  st_buffer(dist = 150) %>% 
  st_bbox() %>% 
  osm.raster( crop = TRUE) %>% 
  tm_shape(.) + 
  tm_rgb() +
  tm_shape(etape_line) + 
  tm_lines(col = couleurs$bleuTour, 
           lwd= 4)+
  # Ajout pt arrivée
  tm_shape(pt_arrivee)+
  tm_symbols(size = 0.8, 
             shape = 23,
             col = couleurs$rougeDanger)

tmap_save(tm =map, 
          filename = here("img", "cartes", "input", glue('Etape{no_etape}_Arr.png')))
