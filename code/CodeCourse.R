#!/usr/bin/env Rscript --vanilla

################################################################################
# 
# Code pour le document de travail en course
#    `code/DocCourse.R`
#
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))

################################################################################ 

tableau_en_course <- function(Etape = 1, km_actuel = 10, vit_actuelle = 44, heure_dep,  language = "FR"){
  
  calcul_iti_etape(Etape , "FR")%>% 
    as_tibble() %>% 
    mutate(
      dur_h_reel = dhours(KM_fait / vit_actuelle),
      time_arr_reel = heure_dep + dur_h_reel, # en fx heure départ réel
      time_arr_reel = format(time_arr_reel, format= "%H:%M" )
    ) %>% 
    select(KM_a_faire,
           KM_fait,
           Emoji,
           Details,
           time_arr_rapide,
           time_arr_reel,
           time_arr_lent) %>% 
    filter(KM_fait >= KM_ACTUEL) %>% 
    kbl(col.names = NULL,
        escape = F, # permet de passer les <br/>
        align = c(rep('c', times = 7))) %>% 
    kable_styling("striped",      # kable_minimal
                  full_width = T, 
                  font_size = 16) %>%
    
    # Conditions des colonnes
    column_spec(2, bold = T) %>%
    column_spec(6, bold = T, italic = T) %>%
    
    # Header tableau
    add_header_above(  c({if (language=="FR") "restant" else "to go"}, 
                         {if (language=="FR") "fait" else "done"},
                         {if (language=="FR") "parcours" else "info"}, 
                         iti_etape$Details$Descr_km[Etape],
                         iti_etape$Details$Vit_rapide[Etape],
                         vit_actuelle %>% round(digits = 1),
                         iti_etape$Details$Vit_lent[Etape])) %>% 
    add_header_above(c( "km"  = 2, 
                        {if(language=="FR") "Info" else "Course"}, 
                        iti_etape$Details$Descr_Villes[Etape], 
                        "km/h" = 3 )) 
  
  
}

################################################################################ 

# Fonction pour sortir l'heure de début de course en bon format

heure_dep_fx <- function(heure, min, sec){

  lubridate::ymd_hms(glue("{year(now())}-{month(now())}-{day(now())} {heure}:{min}:{sec}")) %>% 
    force_tz( tzone = "UTC")
}

################################################################################ 

# Fonction pour prévision hors délai en fonction de la vitesse actuelle

prevision_horsdelai <- function(Etape = 1, km_actuel = 10, vit_actuelle = 44, heure_dep,  language = "FR"){

  calcul_iti_etape(Etape , "FR")%>% 
    as_tibble() %>% 
    mutate(
      dur_h_reel = dhours(KM_fait / vit_actuelle),
      dur_h_horsdelai = dur_h_reel * 1.2,
      diff_hors_delai = dur_h_horsdelai - dur_h_reel,
      time_arr_reel = heure_dep + dur_h_reel, # en fx heure départ réel
      time_arr_reel = format(time_arr_reel, format= "%H:%M:%S" ),
      time_hors_delai = heure_dep + dur_h_horsdelai,
      time_hors_delai = format(time_hors_delai, format= "%H:%M:%S" )
    ) %>% tail(1) %>% 
    select(
      "Délai 20%" = diff_hors_delai,
      "Heure arrivée prévue" = time_arr_reel,
      "Heure hors-délai prévue" = time_hors_delai)
  
}