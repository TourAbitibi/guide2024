#!/usr/bin/env Rscript --vanilla

#########################################################################################
# Créer le raster avec les données d'élévation et sauvegarder vers .tif                 #
# Opération manuelle à faire seulement si les parcours sortent de la région habituelle  #
#                                                                                       #
# Input : Shapefile contenant les gpx des parcours - "gpx/output/parcours.shp"          #
# Output : le Raster de la région complète "rasterElevation/elv_parcours.tif"           #
#                                                                                       #
#########################################################################################

# -[ ] Vérifier comment calculer le pourcentage de pente pour passer comme couleur à la ligne du graphique d'élévation

    # Fonction : lag ou lead(elv, n=1 row derrière ou devant)

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))

# Si besoin de mettre à jour à partir de nouveaux .gpx
#  source(here("code","_importExportGPX.R"))
#  source(here("code","_elv_parcours.R"))



# Lecture du shapefile enregistré contenant les parcours 
parcours <- st_read(here("gpx/output/parcours.shp"))
elv_parcours <- raster(here("rasterElevation/elv_parcours.tif"))

# Lecture des données d'élévations enregistrées
dist_df <-read_csv(here("elevParcours/elev_parcours.csv"), 
                   col_types = list(col_integer(), col_double(), col_integer()),
                   show_col_types = FALSE)

################################################################################
################################################################################

# Visualisation
# mapview(parcours, lwd = 2,
#         color = palette.colors(n=7, palette="ggplot2"),
#         layer.name = "Étape")

################################################################################

# Fonction pour trouver élévation y pour une valeur x données

elv_f_x <- function(df, num_etape, x_km ){
  
 df %>% 
    filter (etape == num_etape) %>% 
    select(-etape) %>% 
    mutate (dist = round(dist, digits = 1)) %>% 
    group_by(dist) %>% 
    summarise(elev = mean(elev, na.rm= TRUE),
              .groups = "drop") %>% 
    filter(dist == round(x_km, digits = 1)) %>% 
    pull(elev) %>% 
    
    return()
  
}

################################################################################

# Fonction pour obtenir les points d'intérêts et leurs élévation

elv_poi <- function(df = dist_df, num_etape){

  poi <- calcul_iti_etape(num_etape, "FR") %>% 
    select (KM_fait, Symbol) %>% 
    filter(Symbol %in% df_POI$values)
  
  
  map(.x = 1:nrow(poi), ~elv_f_x(df, num_etape, x = poi$KM_fait[.x])) %>% 
    lapply(data.frame) %>% 
    bind_rows() %>% 
    cbind(poi,.) %>% 
    rename(elev = X..i..) %>% 
    return()
}

################################################################################ 

# Correction pour circuit urbain (gpx tracé sur 1 tour seulement, mais utilisé X fois)

df_circuit_urbain <- function(df = dist_df, num_etape){
  # Pour un cc, nous avons un tracé d'un tour qui a été étiré sur X tours.
  # On doit le ramener sur 1 tours et ensuite le multiplier par nb_tour
  
  km_tour <- iti_etape$Details$KM_par_tours[num_etape]
  
  nb_tour <- iti_etape$Details$Nb_tours[num_etape]
  
  poi <- calcul_iti_etape(num_etape, "FR") %>% 
    select (KM_fait, Symbol) %>% 
    filter(Symbol %in% df_POI$values)
  
  
  ## Actuellement, les 12 tours sont corrigés sur 1 tour seulement.
  ### Il faut faire le fichier fois le nombre de tours  dans le fichier dist_df
  
  dist_df_circuit_base <- dist_df %>% filter (etape == num_etape) %>% 
    select(-etape) %>% 
    mutate(dist = dist/nb_tour) %>% 
    mutate (dist = round(dist, digits = 1)) %>% 
    group_by(dist) %>% 
    summarise(etape = num_etape,
              dist = mean(dist), 
              elev= mean(elev))
  
  dist_df_circuit <- dist_df_circuit_base
  
  for (tour in 1:(nb_tour - 1)) { 
    
    dist_df_circuit_supp <- dist_df_circuit_base %>% mutate(dist= dist + tour *km_tour)
    
    dist_df_circuit <- rbind(dist_df_circuit, dist_df_circuit_supp)
  }
  
  dist_df_circuit %>% 
    return()
}

################################################################################

# - [x] Français et Anglais
# - [x] Symbole possible sur KOM, Sprint, $, ... 
# - [x] Légende en bas du graphique complet seulement
# - [x] Utilisation des couleurs pour chaque type de POI, tel que tableau
# - [x] Graphique pour derniers 3 / 5.4 km



graph_elev_complet <-  function(df, num_etape, iti_etape , language, isCircuitUrbain = FALSE){
  
  # Points d'intérêts
  if (isCircuitUrbain == TRUE){
    df= df_circuit_urbain(df,num_etape)
    poi_etape <- elv_poi(df, num_etape) %>%
      rename(dist = KM_fait) %>% 
      as_tibble()
  }
  else{
    poi_etape <- elv_poi(df, num_etape) %>%
      rename(dist = KM_fait) %>% 
      as_tibble()
  }
  # Élévation regroupée par chaque 0.1km
  data_graph_base <- df %>% 
    filter(etape == num_etape) %>% 
    mutate (dist = round(dist, digits = 1)) %>% 
    group_by(dist) %>% 
    summarise(elev = mean(elev, na.rm= TRUE),
              .groups = "drop")

  graph <- ggplot(NULL, aes(x= dist, y = elev))+
    geom_line(data = data_graph_base, color=couleurs$bleuTour, linewidth=0.8, show.legend = FALSE)+
    {if (language == "FR") {ggtitle(glue("Étape {num_etape} - Profil topographique"),
                                subtitle = glue("{iti_etape$Details$Descr_Villes[num_etape]} ({iti_etape$Details$Descr_km[num_etape]})"))} else {ggtitle(glue("Stage {num_etape} - Topographic profile"),
                   subtitle = glue("{iti_etape$Details$Descr_Villes[num_etape]} ({iti_etape$Details$Descr_km[num_etape]})"))}}+
      xlab("Distance (km)")+
      ylab("Elevation (m)")+
      scale_x_continuous(n.breaks = 10)+
      theme_ipsum()+
    geom_point(data = poi_etape, 
               aes(color = Symbol),
               size = 4,
               alpha = 0.9)+
    theme(legend.position="bottom",
          legend.title = element_blank())+
    scale_color_manual( labels = {if (language == "FR") df_POI$label_fr else df_POI$label_en},
                        breaks = df_POI$values,
                        values = df_POI$color)
  
  return(graph)
}           

# Test
## graph_elev_complet(dist_df, 2, "FR")

################################################################################
################################################################################

graph_elev_arrivee <-  function(df , num_etape , iti_etape, language , km_finaux, isCircuitUrbain = FALSE){

  # Points d'intérêts
  if (isCircuitUrbain == TRUE){
    df= df_circuit_urbain(df,num_etape)
    poi_etape <- elv_poi(df, num_etape) %>%
    rename(dist = KM_fait) %>% 
    filter(dist >= (max(dist)- km_finaux)) %>% 
    as_tibble()
  }
  else{
    poi_etape <- elv_poi(df, num_etape) %>%
      rename(dist = KM_fait) %>% 
      filter(dist >= (max(dist)- km_finaux)) %>% 
      as_tibble()
  }
  # Élévation regroupée par chaque 0.1km
  data_graph_base <- df %>% 
    filter(etape == num_etape) %>% 
    mutate (dist = round(dist, digits = 1)) %>% 
    group_by(dist) %>% 
    summarise(elev = mean(elev, na.rm= TRUE),
              .groups = "drop") %>% 
    filter(dist >= (max(dist)- km_finaux))
  
  
  graph <- ggplot(NULL, aes(x= dist, y = elev))+
    geom_line(data = data_graph_base, color=couleurs$bleuTour, linewidth=0.8, show.legend = FALSE)+
    {if (language == "FR") {ggtitle(glue("Étape {num_etape} - Profil topographique - {km_finaux} derniers km"),
                                subtitle = glue("{iti_etape$Details$Descr_Villes[num_etape]} ({iti_etape$Details$Descr_km[num_etape]})"))} else {ggtitle(glue("Stage {num_etape} - Topographic profile - Last {km_finaux} km"),
                                                                                                                                                         subtitle = glue("{iti_etape$Details$Descr_Villes[num_etape]} ({iti_etape$Details$Descr_km[num_etape]})"))}}+
    xlab("Distance (km)")+
    ylab("Elevation (m)")+
    scale_x_continuous(n.breaks = 10)+
    theme_ipsum()+
    geom_point(data = poi_etape, 
               aes(color = Symbol),
               size = 4,
               alpha = 0.9,
               show.legend = FALSE)+
    theme(legend.position="bottom",
          legend.title = element_blank())+
    scale_color_manual( labels = {if (language == "FR") df_POI$label_fr else df_POI$label_en},
                        breaks = df_POI$values,
                        values = df_POI$color)
  
  return(graph)
  
}   

################################################################################
# Créations de tous les graphiques en .png                                     #
################################################################################

creation_graphs_elev <- function(etape, lang = "FR", isCircuitUrbain=FALSE){
  
  km_tour <- iti_etape$Details$KM_par_tours[etape]
  
  km <- if_else(km_tour > 0, km_tour, 3) 
  
  graph_elev_complet(dist_df, etape, iti_etape, lang, isCircuitUrbain) %>% 
    ggsave( filename = here("img","elev", glue("Etape{etape}_Full_{lang}.png")), width =8, height = 5, dpi= 300, bg= "white")  
  
  graph_elev_arrivee(dist_df, etape, iti_etape ,lang , km, isCircuitUrbain) %>% 
    ggsave( filename = here("img","elev", glue("Etape{etape}_Final_{lang}.png")), width =8, height = 3, dpi= 300, bg= "white")

}


# Création des 7 étapes dans les 2 langues SAUF circuit urbain
walk(.x = c(1,2,3,4,5,7), ~creation_graphs_elev(.x, "FR"))
walk(.x = c(1,2,3,4,5,7), ~creation_graphs_elev(.x, "EN"))

# Création du circuit urbain
walk(.x = c(6), ~creation_graphs_elev(.x, "FR", isCircuitUrbain=TRUE))
walk(.x = c(6), ~creation_graphs_elev(.x, "EN", isCircuitUrbain=TRUE))

################################################################################ 

### Tests - ajustements manuels ###
# source(here("code","_import_itineraire.R"))
# walk(.x = c(7), ~creation_graphs_elev(.x, "FR"))

