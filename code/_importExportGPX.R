#!/usr/bin/env Rscript --vanilla

################################################################################
# Importer les fichiers GPX en input
# Sauvegarder vers un shapefile en output
# Opérations manuelle à faire seulement si nouveaux .gpx au dossier
#
# Input :fichiers gpx de chacune des étapes : "gpx/input/Tour20**_*.gpx"
# Output : Shapefile contenant tous les parcours : "gpx/output/parcours.shp" 
#
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))

# df des détails
details <- iti_etape$Details %>% rename(etape = Etape)

################################################################################

# Import des GPX de courses

path <- here("gpx","input")

# Lire les fichiers GPX correspondant aux parcours du Tour dans le fichier input
gpx_files <- sort(list.files(path = path,
                             pattern = "^Course.*gpx$",
                             full.names = TRUE))

# Liste des étapes présentes en gpx (en fx du chiffre dans le nom du Course_x.gpx)
gpx_files_stages <- str_replace(gpx_files, ".*_(\\d).gpx", "\\1") %>% as.double()

ui_done("Les {ui_field('étapes')} {ui_value(gpx_files_stages)} possèdent un fichier gpx de course.")

# Import et concaténation des GPX - parcours  (couche tracks)
parcours <- map_dfr(gpx_files_stages, ~st_read(gpx_files[.x], layer = "tracks"), .id = "etape") %>% 
  mutate(etape = as.double(etape)) %>% 
  select(etape, name )

# Joindre les détails en provenance du fichier excel (details)
parcours <- parcours %>% 
  left_join(y=details, by = "etape") %>% 
  mutate(name = Nom_Courts_FR) %>% 
  select(etape, name, Jour, Date, time_depart, time_arrivee, Descr_km, KM_Total, KM_Neutres, 
          Nb_tours, KM_par_tours) %>% 
  rename_all(tolower) %>% 
  rename (h_dep = time_depart,
          h_arr = time_arrivee)


# Correction CRS
parcours <- st_transform(parcours, crs = 32198)

################################################################################

# Points POI liés au GPX  (couche waypoints)
## Utilisation de mots clés [KOM, Bonus, Maire] dans le name du POI pour sortir les points à afficher
points <- map_dfr(gpx_files_stages, ~st_read(gpx_files[.x], layer = "waypoints"), .id = "etape") %>% 
  mutate(etape = as.double(etape),
         values = case_when(  str_detect(tolower(name), "start" ) ~ "Green",  # même noms que df_POI
                            str_detect(tolower(name), "kom" ) ~ "Climb",
                            str_detect(tolower(name), "bonus" ) ~ "Sprint",
                            str_detect(tolower(name), "maire" ) ~ "Mayor",
                            TRUE ~ NA_character_)) %>% 
  drop_na(values) %>% 
  select(etape, name, values) %>% 
  left_join(y = df_POI, by = "values") %>% 
  rename(type = values) 

ui_info("Il y a {ui_value(nrow(points))} POIs de course importés")

# Correction CRS
points <- st_transform(points, crs = 32198)

# Enregistrement des points comme .shp
st_write(points,
         here("gpx/output/points_parcours.shp"),
         append=FALSE) 


################################################################################

# Sauvegarde parcours
sauvegarde_requise <- function(){
  st_write(parcours,
         here("gpx/output/parcours.shp"),
         append=FALSE) # pour écrire par dessus
  
  ui_done("Sauvegarde de {ui_field('gpx/output/parcours.shp')} faite!")
}

################################################################################

# Vérifier si les fichiers ont changés avant de faire la sauvegarde
# car création de longues opérations dans le Snakefile
# (création .tif, .csv aux prochaines étapes)

## Vérifier si le parcours.shp existe
# 
# ui_todo("Vérifier si le parcours.shp a été modifié avant de le modifier.")
# 
# parcours_en_memoire = NULL # assignation initiale
# 
# if (file.exists(here("gpx","output","parcours.shp"))) { parcours_en_memoire = st_read(here("gpx/output/parcours.shp"))}     
# 
# ## Vérifier si les 2 parcours sont exactement les mêmes.
# meme_parcours <- all(parcours == parcours_en_memoire)
# 
# a_sauvegarder <- ifelse(!is.na(meme_parcours) & meme_parcours, FALSE, TRUE)
# 
# ## Sauvegarder seulement si a changé
# ifelse(a_sauvegarder,  sauvegarde_requise(),
#        "Pas besoin d'écrire `parcours.shp` à nouveau : aucun changement")
    
sauvegarde_requise()   
