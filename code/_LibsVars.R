################################################################################
# Importer les librairies
# Variables fixes communes à tous les fichiers
################################################################################

# Librairies

librarian::shelf(quiet = TRUE,
  bookdown,
  knitr,
  rmarkdown,
  tidyverse,
  ggtext,
  lubridate,
  mapview,
  readxl,
  formattable,
  kableExtra,
  magick,
  webshot,
  hrbrthemes,
  glue,
  raster,
  rgdal,
  elevatr,
  #rosm,
  sf,
  mapview,
  units,
  #tmap,
  RColorBrewer,
  scales,
  conflicted,
  here,
  png,
  usethis # https://usethis.r-lib.org/reference/ui.html --> ui_info, ui_todo, ...
)

# Gestion des conflits
conflict_prefer("select", "dplyr", quiet = TRUE)
conflict_prefer("filter", "dplyr", quiet = TRUE)

# remotes::install_github("r-spatial/mapview")

#------------------------------------------------------------------------------#

# Liste des paramètres (en remplacement des différents params pour chacun des projets)

params <- tibble(
    annee = 2024,
    dates_compl =  "16 au 21 juillet 2024",
    dates_compl_EN = "July 16 to 21st, 2024",
    lienWeb = "https://tourabitibi.github.io/guide2024/",  # Lien web de base
    ville = "Val-d'Or",
    position_ligne_arrivee = "Hôtel de Ville",
    position_ligne_arrivee_EN = "Town Hall",
    rue_ligne_arrivee = "2e avenue",
    nom_centrale = "Polyvalente Le Carrefour",
    adresse_centrale = "125 rue Self, Val-d'Or (Qc) J9P 3N2",
    langue = "FR",  # FR ou EN, FR par défaut
    input_output = "input",  #Quel dossier pour afficher les cartes des tracés : Full, Dep, Arr.
    sponsor = "Glencore",
    nb_etapes = 7,
    nb_equipes = 16,
    # Challenge Sprint
    nb_coureurs_sprint = 20, # 16 ou 20 ou 24
    nb_coureurs_sprint_par_vague = nb_coureurs_sprint/4, # 4 vagues : 4, 5 ou 6 coureurs pour la vague qualification
    distance_totale_sprint = 600
)

# Paramètres calculés 

# Edition  (52e en 2022)
params$edition <-params$annee - 2022 + 52

# Edition Sprint (10e en 2023)
params$edition_ChallengeSprint <-params$annee - 2023 + 10

# Nombre de coureurs @ 6/équipe
params$nb_coureurs <- 6 * params$nb_equipes

#------------------------------------------------------------------------------#

# Liste des couleurs

couleurs <- list(
                  bleuTour = "#00414F",
                  jauneTour = "#eac11d",
                  brunMaillot = "#8B4513", # à valider
                  orangeMaillot = "#EE9A00", # à valider
                  orangePale = "#ffcf78",
                  vertMaillot = "#66CD00", # à valider
                  blueSprintMaire = "#00008B",
                  bluePale = "#d9d9ff",
                  rougeDanger = "#D7261E",
                  depart = "#006400"
                )

# Bon site de références pour couleurs complémentaires :
#  https://www.colorhexa.com/

#------------------------------------------------------------------------------#

# Listes ordonnées

list_parcours <- unlist(map(1:7, ~glue("parcours{.x}")))
list_parcours <- ordered(list_parcours, levels = list_parcours)

list_etapes <- unlist(map(1:7, ~glue("Etape{.x}")))
list_etapes <- ordered(list_etapes, levels = list_etapes)

df_POI <- tribble(
  ~label_fr,      ~label_en,      ~values,  ~labels, ~color,
  "Départ",       "Start",        "Green",  "",      couleurs$depart,
  "GPM",          "KOM",          "Climb",  "KOM",   couleurs$vertMaillot,
  "Sprint Bonif", "Bonif Sprint", "Sprint", "Bonus", couleurs$orangeMaillot,
  "Sprint Maire", "Mayor Sprint", "Mayor",  "$$",    couleurs$blueSprintMaire,
  "Arrivée",      "Finish",       "Finish", "Fin",   couleurs$brunMaillot
) %>% 
  mutate(values = ordered(values, levels = values))


################################################################################ 

# Liste des maillots

maillots_liste<- tribble(
    ~Maillot, ~Jersey,  
    "Brun", "Brown", 
    "Orange", "Orange", 
    "Pois", "KOM", 
    "Bleu", "Blue") %>% 
  mutate(Maillot = Maillot %>% as.factor(),
         Jersey = Jersey %>%  as.factor())


# Liste des Médailles et emoji correspondant

  ## https://www.compart.com/fr/unicode/search?q=m%C3%A9daille#characters

medaille_emoji <- tribble(
  ~Position, ~emoji,
  1, "&#129351;",
  2, "&#129352;",
  3, "&#129353;"
)

################################################################################ 


# Liens règlements UCI
## PDF des règlements UCI

uci_p1_FR <- "https://assets.ctfassets.net/761l7gh5x5an/wQympSG6EWlKq6o6HKw9E/6a659ce56c6a1679ebc29d2aee0b4990/1-GEN-20240617-F.pdf"
uci_p2_FR <- "https://assets.ctfassets.net/761l7gh5x5an/5zPSLYnROebDjMLDWUnLsM/f9f2e99838d85dd8764c6f095c8a9adb/2-ROA-20240617-F.pdf"

uci_p1_EN <- "https://assets.ctfassets.net/761l7gh5x5an/wQympSG6EWlKq6o6HKw9E/dbf22e49f7cde9ae61df6180c7a90c8e/1-GEN-20240617_E.pdf"
uci_p2_EN <- "https://assets.ctfassets.net/761l7gh5x5an/6FEzFHeA2oKMBGb5sdIvQ7/2bebd126b4e4937f41760c4fc0e085c1/2-ROA-20240617-E.pdf"

uci_financial <- "https://assets.ctfassets.net/761l7gh5x5an/3XSdDT5GZNHaRDKjjqE4bo/d586af08d8940967b7e4cdac1d14bc18/ROA-20231008_-_2024_Road_Financial_Obligations.pdf"
