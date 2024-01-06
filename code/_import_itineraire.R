################################################################################
# Lecture du ficher excel "itinéraire" ,
# Calcul des heures d'arrivée moyenne,
# Création des tableau de description détaillé des étapes
#
# Input : fichier Excel "excel/Itineraires.xlsx"
# Output : 
#  - fonctions pour créer tableau
#  - df `iti_etape` contenant tous les détails du fichier Excel
#
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

# Fonction pour importer les feuilles du fichier excel de travail
read_itinerairexlsx <- function(filename, tibble = FALSE) {
    sheets <- readxl::excel_sheets(filename)
    x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
    if(!tibble) x <- lapply(x, as_tibble)  # as.data.frame
    names(x) <- sheets
    
    # Transformer les dates et calcul heures arrivées
    x$Details <- x$Details %>% 
      mutate(Date = as_datetime(x$Details$Date),
             dttm_depart = Date + hours(Heure_dep) + minutes(min_dep),
             time_depart = format(dttm_depart, format = "%H:%M"),
             dttm_arrivee = dttm_depart + 
                            dhours(KM_Total/Vit_moy),
             time_arrivee = format(dttm_arrivee, format = "%H:%M")
             )
    
    return(x)
}


# Importer les itinéraires et détails du fichier Excel
iti_etape <- read_itinerairexlsx(here("excel","Itineraires.xlsx"))


# Calculs des temps de passage par étape

calcul_iti_etape <- function(Etape, language = "FR"){

  # Description complète de l'étape
  orig_name <-paste0("iti_etape$Etape_", Etape, sep="")
  df_orig <- eval(parse(text=orig_name)) %>% 
    mutate(KM_reel = as.double(KM_reel))
  
  #heure_dep <- iti_etape$Details$Heure_dep[Etape]
  #min_dep <- iti_etape$Details$min_dep[Etape]
  
  # df `Détails` pour l'étape
  details <- iti_etape$Details[Etape,]
  
  df <- df_orig %>% 
    mutate(KM_fait = round(KM_reel - details$KM_Neutres, 1),
           KM_a_faire = round(max(KM_fait)-KM_fait, 1),
           km_fait_reel = KM_reel - KM_a_faire,
           
           dur_h_rapide = dhours(KM_reel /details$Vit_rapide) ,
           dur_h_moy = dhours(df_orig$KM_reel /details$Vit_moy),
           dur_h_lent = dhours(df_orig$KM_reel /details$Vit_lent),
           
           time_arr_rapide = details$dttm_depart + dur_h_rapide ,
           time_arr_moy = details$dttm_depart + dur_h_moy,
           time_arr_lent = details$dttm_depart + dur_h_lent,
           
           time_arr_rapide = format(time_arr_rapide, format= "%H:%M" ),
           time_arr_moy = format(time_arr_moy, format= "%H:%M" ),
           time_arr_lent = format(time_arr_lent, format= "%H:%M" )) %>% 
    
    dplyr::select( -km_fait_reel) %>% 
    merge(x=., y = iti_etape$Lexique, by = "Symbol", all.x = TRUE ) %>% 
    arrange(KM_fait) %>% 
    {if (language == "FR") dplyr::select (.,-Details_ANG, -Info_ANG ) %>% rename(Details = Details_FR, Info = Info_FR) 
      else dplyr::select (.,-Details_FR, -Info_FR)  %>% rename(Details = Details_ANG, Info = Info_ANG) }
    
  return(df)

}

################################################################################

# Création tableau description détaillée


tableau_Descrip_BASE <- function(Etape = 1, language = "FR"){
  
  descr_iti <- calcul_iti_etape(Etape, language)
  
  descr_iti %>% 
    select(KM_a_faire,
           KM_fait,
           Emoji,
           Details,
           time_arr_rapide,
           time_arr_moy,
           time_arr_lent) %>% 
    kbl(col.names = NULL,
        escape = F, # permet de passer les <br/>
        align = c(rep('c', times = 7))) %>% 
    kable_styling("striped",      # kable_minimal
                  full_width = T, 
                  font_size = 16) %>%
    
    # Conditions des colonnes
    column_spec(2, bold = T) %>%
    
    # Conditions de rangées
    row_spec(which(descr_iti$Symbol == "Green",), bold = F, color = "darkgreen" ) %>%
    row_spec(which(descr_iti$Symbol == "Mayor",), bold = F, color = couleurs$blueSprintMaire ) %>% # , background = ""
    row_spec(which(descr_iti$Symbol == "Sprint",), bold = F, color = couleurs$orangeMaillot ) %>%
    row_spec(which(descr_iti$Symbol == "Climb",), bold = F, color = couleurs$vertMaillot ) %>%
    row_spec(which(descr_iti$Symbol == "Danger",), bold = F, color = couleurs$rougeDanger ) %>%
    row_spec(which(descr_iti$Symbol == "Finish",), bold = T, color = couleurs$brunMaillot) %>%
    
    # Header tableau
    add_header_above(  c({if (language=="FR") "restant" else "to go"}, 
                         {if (language=="FR") "fait" else "done"},
                         {if (language=="FR") "parcours" else "info"}, 
                         iti_etape$Details$Descr_km[Etape],
                         iti_etape$Details$Vit_rapide[Etape],
                         iti_etape$Details$Vit_moy[Etape],
                         iti_etape$Details$Vit_lent[Etape])) %>% 
    add_header_above(c( "km"  = 2, 
                        {if(language=="FR") "Info" else "Course"}, 
                        iti_etape$Details$Descr_Villes[Etape], 
                        "km/h" = 3 )) 
  
  
}

# Tableau typique avec footer complet

tableau_Descrip_Etape <- function(Etape = 1, language = "FR"){

  tableau_Descrip_BASE(Etape, language) %>%  # Tableau de base sans footer
    {if (language == "FR")
    footnote(.,general  = c("Sprint bonification : 3-2-1 sec & 6-4-2 pts",
                         "Arrivée finale : 10-6-4 sec & 30-24-20-16-12-10-8-6-4-2 pts",
                         "GPM : 5-3-2 points"
                         ),
             general_title = "Points et bonifications :",
             title_format = c("italic", "bold"),
             escape= FALSE) else
      footnote(.,general  = c("Bonus sprint : 3-2-1 sec & 6-4-2 pts",
                            "Final Finish : 10-6-4 sec & 30-24-20-16-12-10-8-6-4-2 pts",
                            "KOM : 5-3-2 points"
      ),
      general_title = "Points and bonifications :",
      title_format = c("italic", "bold"),
      escape= FALSE)
    }

}

# Création tableau description détaillée - demi-étape route 

tableau_Descrip_Etape_Demi <- function(Etape = 1, language = "FR"){
  
  tableau_Descrip_BASE(Etape, language) %>% # Tableau de base sans footer
    {if (language == "FR")
      footnote(.,general  = c("Sprint bonification : 3-2-1 sec & 6-4-2 pts",
                              "Arrivée finale : 6-4-2 sec & 30-24-20-16-12-10-8-6-4-2 pts",
                              "GPM : 5-3-2 points"
      ),
      general_title = "Points et bonifications :",
      title_format = c("italic", "bold"),
      escape= FALSE) else
        footnote(.,general  = c("Bonus sprint : 3-2-1 sec & 6-4-2 pts",
                                "Final Finish : 6-4-2 sec & 30-24-20-16-12-10-8-6-4-2 pts",
                                "KOM : 5-3-2 points"
        ),
        general_title = "Points and bonifications :",
        title_format = c("italic", "bold"),
        escape= FALSE)
    }
  
}

# Création tableau description détaillée - arrivée au sommet 

tableau_Descrip_Etape_Sommet <- function(Etape = 1, language = "FR"){
  
  tableau_Descrip_BASE(Etape, language) %>% # Tableau de base sans footer
    {if (language == "FR")
      footnote(.,general  = c("Sprint bonification : 3-2-1 sec & 6-4-2 pts",
                              "Arrivée finale : 10-6-4 sec & 30-24-20-16-12-10-8-6-4-2 pts",
                              "GPM : 5-3-2 points",
                              "GPM - arrivée au sommet : 10-6-4 points"
      ),
      general_title = "Points et bonifications :",
      title_format = c("italic", "bold"),
      escape= FALSE) else
        footnote(.,general  = c("Bonus sprint : 3-2-1 sec & 6-4-2 pts",
                                "Final Finish : 10-6-4 sec & 30-24-20-16-12-10-8-6-4-2 pts",
                                "KOM : 5-3-2 points",
                                "KOM - mountain top finish : 10-6-4 points"
        ),
        general_title = "Points and bonifications :",
        title_format = c("italic", "bold"),
        escape= FALSE)
    }
  
}


################################################################################

# Fonction - calcul de l'heure de passage à un km donné (pour POIs)
calcul_h_passage <- function(km, Etape = 1){
  
  vit_moy_etape <- iti_etape$Details[(Etape),] %>% select(Vit_moy) %>% pull()
  dep_etape_time <- iti_etape$Details[(Etape),] %>% select(dttm_depart) %>% pull()
  vit_moy_etape <- iti_etape$Details[(Etape),] %>% select(Vit_moy) %>% pull()
  duree <- dhours(km /vit_moy_etape)
  time_passage_moy = dep_etape_time + duree
  time_passage_moy_h_m = format(time_passage_moy, format= "%H:%M" )
  
  return(time_passage_moy_h_m)
  
}

# Fonction pour obtenir les POIs de signalisation d'une étape
POIs_signalisation <- function(Etape = 1){
  
  details <- iti_etape$Details[Etape,]
  neutre_etape <- details$KM_Neutres
  
  points_signalisation %>% 
    filter(etape == Etape) %>% 
    as_tibble() %>% 
    arrange(KM_reel, sign_id) %>% 
    mutate(time = calcul_h_passage(KM_reel, Etape),
           KM_course = KM_reel - neutre_etape) %>% 
    select(KM_reel, 
           KM_course,
           time,
           ID = sign_id,
           Détails = details,
           Type = type,
           Fonction = fonct,
           Responsable = resp,
           image) %>% 
    mutate( Type = case_when( Type == "terre_plein" ~ "Terre-plein",
                              Type == "virage_intersection" ~ "Virage / intersection",
                              Type == "section_gravier" ~ "Section Gravier",
                              Type == "danger" ~ "Danger",
                              TRUE ~ Type),
            Fonction = case_when( Fonction == "signaleur_fixe" ~ "Signaleur Fixe",
                                  Fonction == "signaleur_moto" ~ "Signaleur Moto",
                                  Fonction == "signalisation_seulement" ~ "Signalisation seulement",
                                  TRUE ~ Fonction),
            Responsable = case_when( Responsable == "ville_depart" ~ paste0("Ville - ", details$VilleDep),
                                     Responsable == "sq_locale" ~ paste0("SQ - ", details$VilleDep),
                                     Responsable == "sq_hotesse" ~ paste0("SQ - ", params$ville),
                                     Responsable == "sq_autre" ~ "SQ - Autre",
                                     Responsable == "sq_usg" ~ "SQ - USG",
                                     Responsable == "signaleur_moto" ~ "Signaleur - Moto",
                                     Responsable == "signaleur_autre" ~ "Signaleur - Autre",
                                     Responsable == "CO_benevole" ~ "Bénévole - CO",
                                     TRUE ~ Responsable)) 
  
}

# Fonction pour obtenir le tableau Kable des POIs de signalisation
POIs_tableau <- function(POIs) {
  
  POIs %>% 
    select(- image, -KM_course) %>% 
    rename("KM Réel" = KM_reel,
           "Heure Passage" = time) %>% 
    kbl(escape = F, 
        align = c(rep('c', times = 7))) %>% 
    kable_styling("striped",
                  full_width = T, 
                  font_size = 16) %>% 
    # Conditions des colonnes
    column_spec(1, bold = T) %>% 
    
    # Conditions rangées
    row_spec(which (str_detect(POIs$Responsable, "SQ") ,), bold = F,  color =  couleurs$blueSprintMaire) %>%   #"#006BB7"
    row_spec(which (str_detect(POIs$Fonction, "Moto") ,), bold = F,  color = couleurs$orangeMaillot ) %>% 
    row_spec(which(POIs$Type == "Danger",), bold = F, color = couleurs$rougeDanger )
}




# Fonction pour affichage du détail de chaque point de signalisation

P_sign_detail_1 <- function(P){
  
  P %>% 
    select(KM_reel, time, Détails)%>% 
    rename("KM Réel" = KM_reel,
           "Heure Passage" = time) %>% 
    kbl(escape = F, 
        align = c('c', 'c','l')) %>% 
    kable_styling("striped",
                  full_width = T, 
                  font_size = 16) %>% 
    # Conditions des colonnes
    column_spec(1, bold = T)
  
}

P_sign_detail_2 <- function(P){
  
  P %>% 
    select(KM_course, Type, Fonction, Responsable)%>% 
    rename("KM Course" = KM_course) %>% 
    kbl(escape = F, 
        align = c('c', 'c', 'c')) %>% 
    kable_styling("striped",
                  full_width = T, 
                  font_size = 16)%>% 
    # Conditions des colonnes
    column_spec(1, bold = T)
  
}
