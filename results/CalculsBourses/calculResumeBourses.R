#!/usr/bin/env Rscript --vanilla

################################################################################
# Calculer les bourses de chaque coureurs avec les résultats
# Sauvegarder un fichier excel recapitulatif
#
# À rouler manuellement à la fin du Tour
#
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))

source(here("results", "CalculsBourses", "_importGrillesBourses.R"))

library(xlsx)

# df des détails
details <- iti_etape$Details
################################################################################

# Import liste des coureurs pour join

listeCoureurs <- read.csv(here("results", "Liste_Coureurs.csv")) %>% 
  select(Bib, Coureur, Equipe = Team)

################################################################################ 

# Calcul pour bourses des Maires

boursesMaires <- read.csv(here("results", "Maires.csv")) %>% 
  as_tibble() %>% 
  drop_na() %>% 
  left_join(details %>% select(Etape,Nom_Courts_FR), by = "Etape") %>% 
  left_join(listeCoureurs, by = "Bib") %>% 
  select(Detail = Nom_Courts_FR,
         Etape,
         Sprint = SprintNumero,
         Bourse,
         Bib,
         Coureur,
         Equipe)

boursesMairesCumulCoureur <- boursesMaires %>% 
  group_by(Bib, Coureur, Equipe) %>% 
  summarise(Bourse = sum(Bourse),
            Nombre = n(),
            .groups = "drop") %>% 
  arrange(-Bourse, -Nombre)

boursesMairesCumulEquipe <- boursesMaires %>% 
  group_by(Equipe) %>% 
  summarise(Bourse = sum(Bourse),
            Nombre = n(),
            .groups = "drop") %>% 
  arrange(-Bourse, -Nombre)

write_csv(boursesMaires, 
          file = here("results", "CalculsBourses", "Tableau_Bourses_Maires.csv"),
          append = FALSE)

write_csv(boursesMairesCumulCoureur, 
          file = here("results", "CalculsBourses", "Maires_CumulCoureurs.csv"),
          append = FALSE)

write_csv(boursesMairesCumulEquipe, 
          file = here("results", "CalculsBourses", "Maires_CumulEquipes.csv"),
          append = FALSE)

################################################################################ 
################################################################################ 

# Calcul bourses - Étapes

## Résultats de chaque étape
resultsEtape <- read.csv(here("results", "Etapes_results.csv")) %>% 
  as_tibble() %>% 
  select(-TempsEtape) %>% 
  drop_na()

## Dernière étape en résultats
maxEtape <- max(resultsEtape$Etape)

## Calcul du montant par étape

calculBourseEtape <- function(noEtape){

  resultsEtape %>% 
    filter(Etape == noEtape & Position <=20) %>% 
    left_join(GrilleBoursesEtapes %>% select(Position, glue("E{noEtape}")), by = "Position") %>%
    mutate(Col = glue("E{noEtape}") %>% as.character()) %>% 
    select(Bib, Col, Position, Bourse = glue("E{noEtape}"))
}

boursesEtapes <- map(1:maxEtape, calculBourseEtape) %>% 
  list_rbind()

################################################################################ 

# Calcul bourses - Classements cumulatifs

## Calcul du montant - Général

boursesGeneral <- read.csv(here("results", "General_results.csv")) %>% 
  as_tibble() %>% 
  drop_na()%>% 
  filter(ApresEtape == maxEtape & Position <=20) %>% 
  left_join(GrilleBoursesGeneral, by = "Position") %>%
  mutate(Col = "General") %>% 
  select(Bib, Col, Position, Bourse )

## Calcul du montant - Points

boursesPoint <- read.csv(here("results", "Points_General_results.csv")) %>% 
  as_tibble() %>% 
  drop_na()%>% 
  filter(ApresEtape == maxEtape & Position <=3) %>% 
  left_join(GrilleBoursesPoints, by = "Position") %>%
  mutate(Col = "Points") %>% 
  select(Bib, Col, Position, Bourse )

## Calcul du montant - KOM

boursesKOM <- read.csv(here("results", "KOM_General_results.csv")) %>% 
  as_tibble() %>% 
  drop_na()%>% 
  filter(ApresEtape == maxEtape & Position <=3) %>% 
  left_join(GrilleBoursesKOM, by = "Position") %>%
  mutate(Col = "GPM/KOM") %>% 
  select(Bib, Col, Position, Bourse )

## Calcul du montant - Jeune

boursesJeune <- read.csv(here("results", "Jeune_General_results.csv")) %>% 
  as_tibble() %>% 
  drop_na()%>% 
  filter(ApresEtape == maxEtape & Position <=3) %>% 
  left_join(GrilleBoursesJeune, by = "Position") %>%
  mutate(Col = "Jeune") %>% 
  select(Bib, Col, Position, Bourse )


## Calcul du montant - Meilleur Abitibien

### Le fichier `ListeAbitibiens.csv` doit contenir la liste de tous les Abitibiens 
### inscrits au Tour et admissible au classement du meilleur Abitibien

listeAbitibiens <- read_csv(here("results", "ListeAbitibiens.csv"),show_col_types = FALSE) %>% pull(Bib)

boursesAbitibien <- read.csv(here("results", "General_results.csv")) %>% 
  as_tibble() %>% 
  drop_na()%>% 
  filter(ApresEtape == maxEtape & Bib %in% listeAbitibiens) %>% 
  arrange(Position) %>% 
  mutate(Position = row_number()) %>% 
  filter(Position == 1) %>% 
  left_join(GrilleBoursesAbitibi, by = "Position") %>%
  mutate(Col = "Abitibien") %>% 
  select(Bib, Col, Position, Bourse )

# Regrouper les bourses individuelles en un dataframe

boursesIndiv <- do.call("rbind", list(boursesEtapes, boursesGeneral, boursesPoint, boursesKOM, boursesJeune, boursesAbitibien)) %>% 
  select(-Position) %>% 
  left_join(listeCoureurs, by = "Bib") %>% 
  pivot_wider(names_from = Col,
              values_from = Bourse,
              values_fill = 0) %>%
  mutate(Total = rowSums(select(.,c(E1, E2, E3, E4, E5, E6, E7, General, Points, 'GPM/KOM', Jeune, Abitibien)))) %>% 
  arrange(-Total, Bib)

# Exporter vers un fichier csv

write_csv(boursesIndiv, 
          file = here("results", "CalculsBourses", "Tableau_Bourses_Individuelles.csv"),
          append = FALSE)

################################################################################ 

# Cumulatif des bourses individuelles, par équipes

boursesIndivCumuleParEquipe <- boursesIndiv %>% 
  group_by(Equipe) %>% 
  summarise(BoursesIndiv = sum(Total),
            .groups = "drop") %>% 
  arrange(desc(BoursesIndiv))

################################################################################ 
################################################################################ 

# Calcul du montant - Classement Équipe

boursesEquipe <- read.csv(here("results", "Equipe_General_results.csv")) %>% 
  as_tibble() %>% 
  drop_na()%>% 
  filter(ApresEtape == maxEtape & Position <=3) %>% 
  left_join(GrilleBoursesEquipe, by = "Position") %>%
  select(Equipe = Team, Position, BourseEquipe = Bourse )

write_csv(boursesEquipe, 
          file = here("results", "CalculsBourses", "Tableau_Classement_Equipes.csv"),
          append = FALSE)


################################################################################ 
################################################################################ 

# Résumé des gains totaux par Équipes

## Maires, Indiv, Classement Equipe

boursesTotalCumulEquipe <- boursesMairesCumulEquipe %>% 
  select(Equipe, BourseMaire = Bourse) %>% 
  full_join(boursesIndivCumuleParEquipe, by = "Equipe") %>% 
  full_join(boursesEquipe %>% select(Equipe, BourseEquipe), by = "Equipe") %>% 
  replace(is.na(.), 0) %>% 
  mutate(Total = rowSums(select(.,c(BourseMaire, BoursesIndiv, BourseEquipe)))) %>% 
  mutate(TotalSansMaire = rowSums(select(.,c(BoursesIndiv, BourseEquipe)))) %>% 
  arrange(-Total,-BourseEquipe, -BoursesIndiv)

write_csv(boursesTotalCumulEquipe, 
          file = here("results", "CalculsBourses", "Tableau_Bourses_CumulTotal_Par_Equipe.csv"),
          append = FALSE)


################################################################################ 
################################################################################ 

# Création d'un fichier excel contenant toutes les infos de bourses

write.xlsx(boursesIndiv, 
           here("results", "CalculsBourses", glue("{params$annee}_Bourses.xlsx")),
           sheetName = 'Individuels',
           append = FALSE)

write.xlsx(boursesMaires, 
           here("results", "CalculsBourses", glue("{params$annee}_Bourses.xlsx")),
           sheetName = 'Maires',
           append = TRUE)

write.xlsx(boursesEquipe, 
           here("results", "CalculsBourses", glue("{params$annee}_Bourses.xlsx")),
           sheetName = 'ClassementEquipe',
           append = TRUE)

write.xlsx(boursesTotalCumulEquipe, 
           here("results", "CalculsBourses", glue("{params$annee}_Bourses.xlsx")),
           sheetName = 'CumulParEquipe',
           append = TRUE)