#!/usr/bin/env Rscript --vanilla

################################################################################
# Importer les valeurs de bourses du fichier excel `prix.xlsx`
#
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

prix_path <- here("excel","prix.xlsx")

################################################################################ 

# Importer les valeurs de bourses

GrilleBoursesEtapes <- read_xlsx(prix_path,
                           sheet = "Verif_UCI",
                           col_types = "numeric",
) %>% 
  slice(2:21) %>% 
  select(
    Position = Places,
    E1,E2,E3,E4,E5,E6,E7
  )

################################################################################ 

GrilleBoursesGeneral <- read_xlsx(prix_path,
                            sheet = "GenTemps",
                            col_types = "numeric",
) %>% 
  slice(1:20) %>% 
  select(
    Position = pos,
    Bourse = montant
  )

################################################################################ 

GrilleBoursesPoints <- read_xlsx(prix_path,
                           sheet = "GenPoints",
                           col_types = "numeric",
) %>% 
  slice(1:3) %>% 
  select(
    Position = pos,
    Bourse = montant
  )

################################################################################ 

GrilleBoursesJeune <- read_xlsx(prix_path,
                          sheet = "GenJeune",
                          col_types = "numeric",
) %>% 
  slice(1:3) %>% 
  select(
    Position = pos,
    Bourse = montant
  )

################################################################################ 

GrilleBoursesKOM <- read_xlsx(prix_path,
                        sheet = "GenKOM",
                        col_types = "numeric",
) %>% 
  slice(1:3) %>% 
  select(
    Position = pos,
    Bourse = montant
  )

################################################################################ 

GrilleBoursesEquipe <- read_xlsx(prix_path,
                           sheet = "GenEquipe",
                           col_types = "numeric",
) %>% 
  slice(1:3) %>% 
  select(
    Position = pos,
    Bourse = montant
  )

################################################################################ 

GrilleBoursesAbitibi <- read_xlsx(prix_path,
                            sheet = "Abitibien",
                            col_types = "numeric",
) %>% 
  slice(1) %>% 
  select(
    Position = pos,
    Bourse = montant
  )