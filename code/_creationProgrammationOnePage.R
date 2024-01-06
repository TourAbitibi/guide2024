#!/usr/bin/env Rscript --vanilla

################################################################################
# Création de la page de programmation en format PDF et png
#
# Input : fichier Excel "excel/Itineraires.xlsx"
#         _import_itineraire.R
# Output : 
#  - images du tableau de la programmation en francais et anglais en format PDF
#  - dans les fichier guide_FR_PDF, guide_EN_PDF / details
#
# ref: https://www.rdocumentation.org/packages/kableExtra/versions/0.6.1/topics/kable_as_image
#
################################################################################

source(here::here("code","/_import_itineraire.R"))

# Librairies et here chargées dans le fichier précédent


# Pour accès à la programmation - dff
source(here("code","programmation.R"))

################################################################################

ui_todo("Création de la programmation en français")

# Tableau Français - Format kable 
prog_FR <- dff %>% 
  select(-presente) %>% 
  
  kbl( col.names = c("Date",  "Épreuve", "Départ", "Arrivée"),
       escape = F, # permet de passer les <br/>
       align = c(rep('l', times = 4))) %>% 
  
  kable_styling("basic",      # kable_minimal
                full_width = T, 
                font_size = 16) 
  


save_kable(prog_FR, here("guide_FR_PDF", "details", "prog.png"),
           bs_theme = "spacelab")

ui_done("Création de la programmation en français OK")


################################################################################
################################################################################

# Tableau Anglais - Format kable 

ui_todo("Création de la programmation en anglais")


prog_EN <- dfe %>% 
  select(-presente) %>% 
  
  kbl( col.names = c("Date",  "Event", "Start", "Finish"),
       escape = F, # permet de passer les <br/>
       align = c(rep('l', times = 4))) %>% 
  
  kable_styling("basic",      # kable_minimal
                full_width = T, 
                font_size = 16) 



save_kable(prog_EN, here("guide_EN_PDF", "details", "prog.png"),
           bs_theme = "spacelab")

ui_done("Création de la programmation en anglais OK")

