#!/usr/bin/env Rscript --vanilla

################################################################################
# Produire un fichier excel contenant :
## Les lignes à tracer sur la route
## Les signaleurs drapeaux jaunes 
## Les motos drapeaux jaunes 
################################################################################ 

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))
library("xlsx")
source(here("code","_import_itineraire.R"))


################################################################################ 

# Lignes sprint

resume_lignes <- function(stage = 1){
  calcul_iti_etape(stage) %>% 
    filter(Symbol %in% c("Climb", "Mayor","Sprint")) %>% 
    mutate(Etape = stage,
           Jour = iti_etape$Details %>% filter(Etape == stage) %>% pull(Jour)) %>% 
    select(Etape,
           Jour,
           "Heure passage" = time_arr_moy,
           Symbol,
           KM = KM_fait,
           Details)
  
}

map_dfr(1:7, resume_lignes) %>% 
  write.xlsx(file = here("export","lignes_tracer_brut.xlsx"),
            sheetName = "lignes_brut",
            row.names = FALSE)


################################################################################ 

# POI Moto

params <- tribble(
  ~ville,
  "Ville hôtesse")

points_signalisation <- st_read(here("gpx","output","points_signalisation.shp"))


# Fonction sortir df des POIs moto-signaleur par étape
POIS_motosignaleur <- function(Etape = 1){

  # Obtenir tous les POIs de signalisation de l'étape
  POIs_signalisation(Etape) %>% filter(Responsable == "Signaleur - Moto")
  

}

Etape <-1 

creer_fichier_execel_moto_sign <- function(Etape =1){

  POIS_motosignaleur(Etape) %>% 
    mutate(Etape = Etape) %>% 
    select(-Fonction,
           -image) %>% 
    write.xlsx(file = here("export","liste_POI_moto.xlsx"),
             sheetName = glue('SignMoto_Etape_{Etape}'))

}

ajout_onglet_fichier_execel_moto_sign <- function(Etape =1){
  
  POIS_motosignaleur(Etape) %>% 
    mutate(Etape = Etape) %>% 
    select(-Fonction,
           -image) %>% 
    write.xlsx(file = here("export","liste_POI_moto.xlsx"),
               sheetName = glue('SignMoto_Etape_{Etape}'),
               append = TRUE)
  
}


creer_fichier_execel_moto_sign(1)
ajout_onglet_fichier_execel_moto_sign(2)
ajout_onglet_fichier_execel_moto_sign(4)
ajout_onglet_fichier_execel_moto_sign(5)
ajout_onglet_fichier_execel_moto_sign(6)
ajout_onglet_fichier_execel_moto_sign(7)