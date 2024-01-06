#!/usr/bin/env Rscript --vanilla

################################################################################
# Importer les fichiers GPX de signalisation en input
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

# Import des GPX de signalisation

path <- here("gpx","input")

# Lire les fichiers GPX correspondant aux parcours du Tour dans le fichier input
gpx_files <- sort(list.files(path = path,
                             pattern = "^Sign.*gpx$",
                             full.names = TRUE))

# Liste des étapes présentes en gpx (en fx du chiffre dans le nom du Course_x.gpx)
gpx_files_stages <- str_replace(gpx_files, ".*_(\\d).gpx", "\\1") %>% as.double()

################################################################################


# Fonction pour importer les feuilles du fichier excel de signalisation
read_signalisationxlsx <- function(filename, tibble = FALSE) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as_tibble)  # as.data.frame
  names(x) <- sheets
  
  return(x)
}

# Importer les signalisations et détails du fichier Excel
signalisation_xlsx <- read_signalisationxlsx(here("excel","signalisation.xlsx"))


# Fonction pour obtenir le détails pour une étape en particulier 
sign_etape <- function(no_etape){
  
  # Données du CSV de signalisation (importé de RWPGS directement)
  csv <- read.csv(here("gpx", "input", glue("Signalisation_{no_etape}.csv"))) %>% 
    janitor::clean_names() %>% 
    select(uniq_id = notes, 
           KM_reel = distance_km_from_start) %>% 
    drop_na() 
  
  # Description complète de l'étape
  orig_name <-paste0("signalisation_xlsx$Etape", no_etape)
  
  eval(parse(text=orig_name)) %>%
    left_join(csv, by = "uniq_id") %>% 
    arrange(KM_reel) %>% 
    mutate(
      etape = no_etape %>% as.double(),
      fonction = as.factor(fonction),
      type = as.factor(type),
      responsable = as.factor(responsable),
      sign_id = paste0("E",no_etape, "_", uniq_id))
  
}


signalisation <- map_dfr(gpx_files_stages, ~sign_etape(.x))

################################################################################
################################################################################

# Points POI liés au GPX  de signalisation (couche waypoints)
# Utilisation du mot "sign" dans le name pour voir si c'est un élément de signalisation

points_signalisation <- map_dfr(gpx_files_stages, ~st_read(gpx_files[match(.x, gpx_files_stages)], layer = "waypoints"), .id= "idx") %>%
  mutate(idx = as.double(idx),
         etape = gpx_files_stages[idx],
         type = case_when(  str_detect(tolower(name), "sign" ) ~ "signalisation",
                            TRUE ~ NA_character_),
         sign_id = paste0("E", etape, "_", name )) %>% 
  drop_na(type) %>% 
  select(name, sign_id) %>% 
  left_join(y = signalisation, by = "sign_id") %>% 
  mutate (image = paste0("E", etape, "/", name, ".png")) %>% 
  select(etape, 
         sign_id, 
         name, 
         details, 
         fonct = fonction, 
         type, 
         resp = responsable,
         image,
         KM_reel) %>% print(n=100)


# Correction CRS
points_signalisation <- st_transform(points_signalisation, crs = 32198)

# Enregistrement des points de signalisation comme .shp
st_write(points_signalisation,
         here("gpx","output","points_signalisation.shp"),
         append=FALSE) 


################################################################################

# Toute l'information de signalisation se retrouve dans le shapefile "points_signalisation.shp"
# Besoin de mettre à jour quand ces fichiers changent :
# - Signalisation_XX.gpx
# - Itineraires.xlsx
# - signalisation.xlsx
# - importExportGPX_Signalisation.R
