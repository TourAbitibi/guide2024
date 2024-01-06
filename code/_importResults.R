#!/usr/bin/env Rscript --vanilla

################################################################################
# Importer les fichiers de résultats en input
# Sauvegarder vers des  csv en output
#
# Commande pour unrar : ` unrar e results/rar/Stage\ Race.rar results/unrar -o+ `
#
################################################################################

here::i_am("guide2024.Rproj")

source(here::here("code","/_LibsVars.R"))

source(here("code","_import_itineraire.R"))


# df des détails
details <- iti_etape$Details %>% rename(etape = Etape)

################################################################################

# Unrar du fichiers `StageRace.rar` provenant du logiciel de RSS

# system(glue('unrar e {here("results","rar", "StageRace.rar")} {here("results","unrar")} -o+'))

################################################################################ 

# Import des fichiers CSV

# Lire les fichiers csv dans le dossier unrar
csv_files <- list.files(path = here("results","unrar"),
                             pattern = ".*csv$",
                             full.names = TRUE)

df_files <- do.call(rbind.data.frame, as.list(csv_files)) %>% 
  as_tibble() %>% 
  rename(file_path = names(.)[1]) %>% 
  mutate(
        stageRSS = str_extract(file_path, "\\s(\\S+)$") %>% str_replace(".csv", "") %>% trimws(),
         
         stage = case_when(
           stageRSS == 1 ~ 1,
           stageRSS == 2 ~ 2,
           stageRSS == 3 ~ 3,
           stageRSS == 4 ~ 4,
           stageRSS == 5 ~ 5,
           stageRSS == 6 ~ 6,
           stageRSS == 7 ~ 7),
           #stageRSS == "3-1" ~ 3,
           #stageRSS == "3-2" ~ 4,
           #stageRSS == 4 ~ 5,
           #stageRSS == 5 ~ 6,
           #stageRSS == 6 ~ 7),
         
         Etape = str_detect(file_path, "Etape") & 
           str_detect(file_path, "Jeune", negate = TRUE),
         
         EtapeJeune = str_detect(file_path, "Etape") & 
           str_detect(file_path, "Jeune"),
         
         General = str_detect(file_path, "General") & 
           str_detect(file_path, "sorted", negate = TRUE) & 
           str_detect(file_path, "Jeune", negate = TRUE),
         
         GeneralJeune = str_detect(file_path, "General") & 
           str_detect(file_path, "sorted", negate = TRUE) & 
           str_detect(file_path, "Jeune"),
         
         Equipe = str_detect(file_path, "Teams") &
           stageRSS != "Equipes" ,
         
         Points = str_detect(file_path, "Sprint"),
         
         KOM = str_detect(file_path, "grimpeur"),
         
         ListeCoureurs = stageRSS == "Coureurs",
         
         ListeEquipes = stageRSS == "Equipes",
         
         ) %>% 
  pivot_longer( !c(file_path, stageRSS, stage),
                names_to = "classification",
               )%>% 
  filter(value) %>% 
  select(-value) %>% 
  arrange(classification)

################################################################################ 

# Liste des étapes présentes en csv
etapes_distinctes_csv <- distinct(df_files, stage) %>% drop_na() %>% arrange(stage)
derniere_etape_terminee <- etapes_distinctes_csv %>% max()

ui_done("La dernière étape terminée est : {ui_value(derniere_etape_terminee)}")

################################################################################
################################################################################ 

# Fonction pour trouvée la ligne du CSV contenant les noms de colonnes

# class : classification pour trouver le bon fichier csv
# motCle : mot se retrouvant seulement dans les noms de colonnes

################################################################################ 

nb_lignes_skip_coureurs <- function(class, motCle){
  
  # Ouvrir la connection vers le fichier
  fc =  df_files %>% 
    filter(classification == class) %>% 
    pull(file_path) %>% 
    file(open = "r", encoding = "UTF-16LE")
  
  rangee_titre = 0 # initialisation
 
  # Trouver la ligne correspondante aux titres de colonnes
  while(length( (l <- readLines(fc, n = 1) ) > 0 )){ 
    
    rangee_titre = rangee_titre + 1
    
    is_detected <- str_detect(l, fixed(motCle))
    
    if(is_detected) {break}
    
  }
  
  return(rangee_titre)
}

################################################################################ 
################################################################################ 

################################################################################
################################################################################ 

# Fonction pour trouvée la ligne du CSV contenant le général de la dernière etape
# Sprints et KOM

# class : classification pour trouver le bon fichier csv
# motCle : mot se retrouvant seulement dans les noms de colonnes
# etape : dernière étape complétée, normalement, `derniere_etape_terminee`

################################################################################ 

nb_lignes_skip_resultat_etape <- function(class, motCle, etape = derniere_etape_terminee){
  
  # Ouvrir la connection vers le fichier
  fc =  df_files %>% 
    filter(classification == class,
           stage == etape) %>%
    pull(file_path) %>% 
    file(open = "r", encoding = "UTF-16LE")
  
  rangee_titre = 0 # initialisation
  
  # Trouver la ligne correspondante aux titres de colonnes
  while(length( (l <- readLines(fc, n = 1) ) > 0 )){ 
    
    rangee_titre = rangee_titre + 1
    
    is_detected <- str_detect(l, fixed(motCle))
    
    if(is_detected) {break}
    
  }
  
  close(fc)
  
  return(rangee_titre)
}

################################################################################ 
################################################################################ 

# Création de la liste des coureurs

class <- "ListeCoureurs"

path_liste_coureurs <- df_files %>% 
  filter(classification == class) %>% 
  pull(file_path)


start_list_coureurs <- read.csv(path_liste_coureurs, 
         sep = ';', 
         skip = nb_lignes_skip_coureurs(class, motCle = 'License'),
         header = FALSE,
         fileEncoding = "UTF-16LE") %>% 
  as_tibble() %>% 
  select(-V9) %>% 
  drop_na() %>% 
  rename( 
    Bib = V1,
    PremAnnee = V2,
    Coureur = V3,
    Team = V4,
    TeamShort = V5,
    License = V6,
    Pays = V7,
    Naissance = V8) %>% 
  mutate(
    Jeune = str_detect(PremAnnee, "#"),
    Team = as_factor(Team),
    TeamShort = as_factor(TeamShort),
    Pays = as_factor(Pays),
    Naissance = as_factor(Naissance)
  ) %>% 
  select(-PremAnnee)

# Écriture de la start list de coureurs vers un .csv

start_list_coureurs %>% write_csv(here("results", "Liste_Coureurs.csv"))

ui_done("Écriture de la start list de coureurs vers {ui_code('Liste_Coureurs.csv')}")

################################################################################ 

# Création de la liste des équipes
start_list_equipes <- start_list_coureurs %>% 
  mutate(BibCategory = 10  * Bib %/% 10 ) %>% 
  select(Team, TeamShort, BibCategory) %>% 
  unique()

# Écriture de la start list d'équipes vers un .csv
start_list_equipes %>% write_csv(here("results", "Liste_Equipes.csv"))
  
ui_done("Écriture de la start list d'équipes vers {ui_code('Liste_Equipes.csv')}")

################################################################################ 
################################################################################ 

# Création des résultats de KOM

class <- "KOM"


path_liste_KOM <- df_files %>% 
  filter(classification == class) 


# Gérer le fait que Stage 3 et 4 n'ont pas de KOM, donc pas de classement
## Étapes 3 et 4 utilisent les mêmes résultats que 2
etapes_effectives_resulstats_KOM <- tibble(etapes_relles = 1:7, etapes_effectives = c(1:  2, 2, 2, 5 : 7)) %>% 
  filter(etapes_relles <= derniere_etape_terminee)

#### Utiliser ces étapes pour un map

map_results_KOM <- function(etape_map){
  etape_relle <- etapes_effectives_resulstats_KOM %>% filter(etapes_relles == etape_map) %>% pull(etapes_relles)
  etape_effective <- etapes_effectives_resulstats_KOM %>% filter(etapes_relles == etape_map) %>% pull(etapes_effectives)
  
  read.csv(path_liste_KOM %>% 
                   filter(stage == etape_effective) %>% 
                  pull(file_path), 
           sep = ';', 
           skip = nb_lignes_skip_resultat_etape(class = class, 
                                                motCle = "General, Général", 
                                                etape = etape_effective),
           header = FALSE,
           fileEncoding = "UTF-16LE") %>% 
    as_tibble() %>% 
      select(-V3, -V4, -V5, -V6, -V7, -V8, -V10) %>% 
      drop_na() %>% 
      rename( 
        Position = V1,
        Bib = V2,
        PointsKOM = V9) %>% 
      mutate(
        ApresEtape = etape_relle)
    
}


# Écriture vers un fichier CSV de résultats des KOM
etapes_effectives_resulstats_KOM$etapes_relles %>% 
  map(\(etapes) .f = map_results_KOM(etapes)) %>% 
  list_rbind() %>% 
  write_csv(here("results", "KOM_General_results.csv"))
 
ui_done("Écriture des KOM vers {ui_code('KOM_General_results.csv')}")

################################################################################ 
################################################################################ 


# Création des résultats de Points (Orange)

class <- "Points"


path_liste_Points <- df_files %>% 
  filter(classification == class) 


# Gérer le fait que Stage 3 n'a pas de points, donc potentiellement pas de classement
# (voir KOM si ajustement requis)
etapes_effectives_resulstats_Points <- tibble(etapes_relles = 1:7, etapes_effectives = 1:7) %>% 
  filter(etapes_relles <= derniere_etape_terminee)

#### Utiliser ces étapes pour un map

map_results_Points <- function(etape_map){
  etape_relle <- etapes_effectives_resulstats_Points %>% filter(etapes_relles == etape_map) %>% pull(etapes_relles)
  etape_effective <- etapes_effectives_resulstats_Points %>% filter(etapes_relles == etape_map) %>% pull(etapes_effectives)
  
  read.csv(path_liste_Points %>% 
             filter(stage == etape_effective) %>% 
             pull(file_path), 
           sep = ';', 
           skip = nb_lignes_skip_resultat_etape(class = class, 
                                                motCle = "General", 
                                                etape = etape_effective),
           header = FALSE,
           fileEncoding = "UTF-16LE") %>% 
    as_tibble() %>% 
    select(-V3, -V4, -V5, -V6, -V7, -V8, -V10) %>% 
    drop_na() %>% 
    rename( 
      Position = V1,
      Bib = V2,
      Points = V9) %>% 
    mutate(
      ApresEtape = etape_relle)
  
}

# Écriture vers un fichier CSV de résultats des Points
etapes_effectives_resulstats_Points$etapes_relles %>% 
  map(\(etapes) .f = map_results_Points(etapes)) %>% 
  list_rbind() %>%
  write_csv(here("results", "Points_General_results.csv"))

ui_done("Écriture du classement au Points vers {ui_code('Points_General_results.csv')}")


################################################################################ 
################################################################################ 

# Gérer le fait que Stage 3 n'a pas de points, donc potentiellement pas de classement
# (voir KOM si ajustement requis)
etapes_effectives_resultats_Etapes <- tibble(etapes_relles = 1:7, etapes_effectives = 1:7) %>% 
  filter(etapes_relles <= derniere_etape_terminee)

#### Fonction Résultats d'Étapes (tout et jeune)

map_results_Etapes <- function(etape_map, class){
  
  path_liste_Etape <- df_files %>% 
    filter(classification == class) 
  
  etape_relle <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_relles)
  etape_effective <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_effectives)
  
  read.csv(path_liste_Etape %>% 
             filter(stage == etape_effective) %>% 
             pull(file_path), 
           sep = ';', 
           skip = nb_lignes_skip_resultat_etape(class = class, 
                                                motCle = "License", 
                                                etape = etape_effective),
           header = FALSE,
           fileEncoding = "UTF-16LE") %>% 
    as_tibble() %>% 
    select(V1, V2, V9) %>% 
    filter(V1 != "",
           V9 != "") %>% 
    drop_na() %>% 
    rename( 
      Position = V1,
      Bib = V2,
      TempsEtape = V9) %>% 
    mutate(
      Position = as.double(Position),
      Etape = etape_relle)
  
}

# Écriture vers un fichier CSV de résultats des Etapes 
etapes_effectives_resultats_Etapes$etapes_relles %>% 
  map(\(etapes) .f = map_results_Etapes(etapes, "Etape")) %>% 
  list_rbind() %>% 
  write_csv(here("results", "Etapes_results.csv"))

ui_done("Écriture des résultats d'étapes vers {ui_code('Etapes_results.csv')}")


# Écriture vers un fichier CSV de résultats des Etapes Jeunes
etapes_effectives_resultats_Etapes$etapes_relles %>% 
  map(\(etapes) .f = map_results_Etapes(etapes, "EtapeJeune")) %>% 
  list_rbind() %>% 
  write_csv(here("results", "Jeunes_Etapes_results.csv"))

ui_done("Écriture des résultats d'étapes jeunes vers {ui_code('Jeunes_Etapes_results.csv')}")

################################################################################ 
################################################################################ 

#### Fonction Résultats Général (tout et jeune)

map_results_General <- function(etape_map, class){
  
  path_liste_Etape <- df_files %>% 
    filter(classification == class) 
  
  etape_relle <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_relles)
  etape_effective <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_effectives)
  
  read.csv(path_liste_Etape %>% 
             filter(stage == etape_effective) %>% 
             pull(file_path), 
           sep = ';', 
           skip = nb_lignes_skip_resultat_etape(class = class, 
                                                motCle = "License", 
                                                etape = etape_effective),
           header = FALSE,
           fileEncoding = "UTF-16LE") %>% 
    as_tibble() %>% 
    select(V1, V2, V9) %>% 
    filter(V1 != "",
           V9 != "") %>% 
    drop_na() %>% 
    rename( 
      Position = V1,
      Bib = V2,
      TempsGeneral = V9) %>% 
    mutate(
      Position = as.double(Position),
      ApresEtape = etape_relle)
  
}

# Écriture vers un fichier CSV de résultats des Général
etapes_effectives_resultats_Etapes$etapes_relles %>% 
  map(\(etapes) .f = map_results_General(etapes, "General")) %>% 
  list_rbind() %>% 
  write_csv(here("results", "General_results.csv"))

ui_done("Écriture du général vers {ui_code('General_results.csv')}")

# Écriture vers un fichier CSV de résultats des Général Jeunes
etapes_effectives_resultats_Etapes$etapes_relles %>% 
  map(\(etapes) .f = map_results_General(etapes, "GeneralJeune")) %>% 
  list_rbind() %>% 
  write_csv(here("results", "Jeune_General_results.csv"))

ui_done("Écriture du général jeune vers {ui_code('Jeune_General_results.csv')}")

################################################################################ 
################################################################################ 

#### Fonction Résultats Général Équipe 

map_results_EquipeGenral <- function(etape_map, class){
  
  path_liste_Etape <- df_files %>% 
    filter(classification == class) 
  
  etape_relle <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_relles)
  etape_effective <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_effectives)
  
  read.csv(path_liste_Etape %>% 
             filter(stage == etape_effective) %>% 
             pull(file_path), 
           sep = ';', 
           skip = 4 + nb_lignes_skip_resultat_etape(class = class, 
                                                motCle = "General classification", 
                                                etape = etape_effective),
           header = FALSE,
           fileEncoding = "UTF-16LE") %>% 
    as_tibble() %>% 
    select(V1, V2, V4) %>% 
    mutate(ligne_gen = str_detect(V2, "General classification")) %>% 
    slice((which(ligne_gen)+1):nrow(.)) %>% 
    select(-ligne_gen) %>% 
    drop_na() %>% 
    rename( 
      Position = V1,
      Team = V2,
      TempsGeneral = V4) %>% 
    mutate(
      Position = as.double(Position),
      ApresEtape = etape_relle)
  
}

# Écriture vers un fichier CSV de résultats des Équipes - Général
etapes_effectives_resultats_Etapes$etapes_relles %>% 
  map(\(etapes) .f = map_results_EquipeGenral(etapes, "Equipe")) %>% 
  list_rbind() %>% 
  write_csv(here("results", "Equipe_General_results.csv"))

ui_done("Écriture du général quipe vers {ui_code('Equipe_General_results.csv')}")


#### Fonction Résultats Général Équipe 

map_results_EquipeEtape <- function(etape_map, class){
  
  path_liste_Etape <- df_files %>% 
    filter(classification == class) 
  
  etape_relle <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_relles)
  etape_effective <- etapes_effectives_resultats_Etapes %>% filter(etapes_relles == etape_map) %>% pull(etapes_effectives)
  
  read.csv(path_liste_Etape %>% 
             filter(stage == etape_effective) %>% 
             pull(file_path), 
           sep = ';', 
           skip = 4 + nb_lignes_skip_resultat_etape(class = class, 
                                                    motCle = "General classification", 
                                                    etape = etape_effective),
           header = FALSE,
           fileEncoding = "UTF-16LE") %>% 
    as_tibble() %>% 
    select(V1, V2, V4) %>% 
    mutate(ligne_gen = str_detect(V2, "General classification")) %>% 
    slice(1:(which(ligne_gen)-1)) %>% 
    select(-ligne_gen) %>% 
    drop_na() %>% 
    rename( 
      Position = V1,
      Team = V2,
      Temps = V4) %>% 
    mutate(
      Position = as.double(Position),
      ApresEtape = etape_relle)
  
}


# Écriture vers un fichier CSV de résultats des Équipes - Etapes
etapes_effectives_resultats_Etapes$etapes_relles %>% 
  map(\(etapes) .f = map_results_EquipeEtape(etapes, "Equipe")) %>% 
  list_rbind() %>% 
  write_csv(here("results", "Equipes_Etapes_results.csv"))

ui_done("Écriture du résultats équipes par étapes vers {ui_code('Equipes_Etapes_results.csv')}")

