#!/usr/bin/env Rscript --vanilla

################################################################################
# Lecture du ficher excel "itinéraire" ,
# Calcul des heures d'arrivée moyenne,
# Création des tableau de description détaillé des étapes
#
# Input : 
#   - parcours.shp
#   - raster elv_parcours.tif
#   - _import_itineraire.R
#
# Output : fichiers csv contenant les élévations corrigées des parcours
#
# --> procédure de calcul des élévations longues, 
#     à faire seulement lors de changement de parcours (GPX)
#
################################################################################


here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))


# Si besoin de mettre à jour le raster à partir de nouveaux .gpx
#   source(here("code","elv_parcours.R"))

# Lecture du shapefile enregistré contenant les parcours et du raster d'élévation
parcours <- st_read(here("gpx/output/parcours.shp"))
elv_parcours <- raster(here("rasterElevation/elv_parcours.tif"))

# Calcul du nombre d'étape   ## -[ ] À VALIDER LORSQU'IL Y AURA DES POINTS EN PLUS DES LIGNES
n_etape <- nrow(parcours)


################################################################################
# Fonction pour extraire les élévations d'une étape
extractionElevation <- function(etape =1 ){

  dist_neutre <- iti_etape$Details$KM_Neutres[etape]
  dist_total <- iti_etape$Details$KM_Total[etape]  # incluant le neutralisé
  dist_circuit <- iti_etape$Details$KM_par_tours[etape] # distance 1 tour
  
  # Extraire les points d'élévation
  topo_elv <- extract(elv_parcours, st_as_sf(parcours[etape,]), along= TRUE, cellnumbers = TRUE)
  
  # Obtenir le profil topo en df
  topo_pts <- as.data.frame(xyFromCell(elv_parcours, topo_elv[[1]][, 1])) %>% 
    st_as_sf(coords = c("x", "y"),
             crs = st_crs(parcours))
  
  # Obtenir la distance entre les points et la distance cumulée
  dist_pts <- st_distance(topo_pts[-1, ], topo_pts[-nrow(topo_pts),],
                          by_element = TRUE)
  dist_parcourue <- as.numeric(set_units(cumsum(dist_pts), km))
  
  # besoin de rescaler entre 0 et max de l'étape (avant d'enlever le neutralisé) 
  # (erreur induite dans l'extraction à coup de 10m..)
  dist_parcourue_corr <- rescale(dist_parcourue, to = c(0, dist_total))
  
  # Transformer en df
  elv_df_etape <- data.frame(etape = etape, 
                        dist = (dist_parcourue_corr - dist_neutre), 
                        elev = topo_elv[[1]][, 2][-1])
  
  return(elv_df_etape)

}
################################################################################

ui_todo("Extraire les {ui_field('élévations')} dans la zone couvrant les parcours.")
ui_warn("Longue opération")

# Extraction de l'élévation sur tous les parcours
elv_df <-map_dfr(.x= 1:n_etape, ~extractionElevation(.x))


ui_done("Extraction des {ui_field('Élévations')} terminées.")

################################################################################

# Sauvegarde du fichier en .csv
write_csv(elv_df, here("elevParcours/elev_parcours.csv"))

ui_done("Écriture du fichier {ui_field('elevParcours/elev_parcours.csv')} terminée.")