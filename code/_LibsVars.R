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
    rue_ligne_arrivee = "2e avenue",
    nom_centrale = "Polyvalente Le Carrefour",
    adresse_centrale = "125 rue Self, Val-d'Or (Qc) J9P 3N2",
    langue = "FR",  # FR ou EN, FR par défaut
    input_output = "input",  #Quel dossier pour afficher les cartes des tracés : Full, Dep, Arr.
    sponsor = "Glencore",
    nb_etapes = 7,
    nb_equipes = 13,
    nb_coureurs_sprint = 16, # 16 ou 24
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

uci_p1_FR <- "https://assets.ctfassets.net/761l7gh5x5an/wQympSG6EWlKq6o6HKw9E/dc4f11d32bd13331be62c834d9070f1c/1-GEN-20230220-F.pdf"
uci_p2_FR <- "https://assets.ctfassets.net/761l7gh5x5an/6l7RYpnS5bOmq32rzaBdNx/77c464d49bad0f321e03f9b0e62e2be8/2-ROA-20230613-F.pdf"

uci_p1_EN <- "https://assets.ctfassets.net/761l7gh5x5an/wQympSG6EWlKq6o6HKw9E/d2911e42e627bbd055483f57cc0027fb/1-GEN-20230220-E.pdf"
uci_p2_EN <- "https://assets.ctfassets.net/761l7gh5x5an/3zdJc5antr1dA3GYeDKdBu/bef82a9d7336e9b798c364066db92581/2-ROA-20230613-E.pdf"

uci_financial <- "https://assets.ctfassets.net/761l7gh5x5an/4LhHQ0knlVpQFA1wf3X2Re/d6066b0cb0f95507c1117cf0e1afdb13/ROA-20220420_-_2023_Road_Financial_Obligations_-v2_PW_Lbo_Corrected_17.06.2022.pdf"
