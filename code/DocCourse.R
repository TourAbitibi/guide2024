#!/usr/bin/env Rscript --vanilla

################################################################################
# 
# Document de travail en course
#   Pour calculer vitesse moyenne et prévision d'arrivée
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/CodeCourse.R"))

ui_info("L'heure est {ui_value(now())}")

################################################################################ 
################################################################################ 
#
# Donnée étape à renseigner une fois

Etape <- 7

HEURE_DEP_REEL <- heure_dep_fx(
  heure = 14,  
  min = 05,
  sec = 44)

# Données à MAJ en cours d'étape
KM_ACTUEL <- 85

################################################################################ 

HEURE_ACTUEL <- now() %>% force_tz( tzone = "UTC")
HEURE_COURSE_ACTUEL <- interval(HEURE_DEP_REEL, HEURE_ACTUEL) %>% as.numeric('hours')
VITESSE_MOY_ACTUEL <- KM_ACTUEL / HEURE_COURSE_ACTUEL

TEMPS_COURSE_ACTUEL <- hms::as_hms(HEURE_COURSE_ACTUEL * 3600)

# Création tableau avec km restant seulement et prévision selon vitesse actuelle
tableau_en_course(Etape, km_actuel = KM_ACTUEL , vit_actuelle = VITESSE_MOY_ACTUEL, 
                  heure_dep = HEURE_DEP_REEL, "FR")

################################################################################ 

ui_done("L'{ui_field('heure du départ réel')} pour l'étape est {ui_value(HEURE_DEP_REEL)}")
ui_done("Après {ui_value(hour(TEMPS_COURSE_ACTUEL))} h {ui_value(minute(TEMPS_COURSE_ACTUEL))} min et {ui_value(second(TEMPS_COURSE_ACTUEL) %>% round(digits = 0))} sec la {ui_field('vitesse moyenne de course')} est de {ui_value(VITESSE_MOY_ACTUEL %>% round(digits =2))} km/h ")


################################################################################ 
# Prévisions du hors délai

prevision_horsdelai(Etape, km_actuel = KM_ACTUEL , vit_actuelle = VITESSE_MOY_ACTUEL, 
                  heure_dep = HEURE_DEP_REEL, "FR")


