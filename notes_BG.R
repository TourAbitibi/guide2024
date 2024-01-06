# Notes Bruno - divers

source("code/_LibsVars.R")

df_test <- tribble(
  ~a, ~b, ~c,
  1, 2, 3,
  4, 5, 6,
  7, 8, 9,
  10,11,12,
  13,14,15,
  16,17,18,
  19,20,21
)

## Case_when
df_test %>% 
mutate(
  chiffre = case_when(a == 1 ~ "un",
                  a == 4 ~ "quatre",
                  a== 6  ~ "six",
                  TRUE ~ NA_character_)
)


# Utilisation full.names dans list.files pour avoir le path complet à passer. 
list.files(path = "gpx/input",
                pattern = "^Tour.*gpx$",
                full.names = TRUE)

# fonctions read_
## col_types = cols(.default = col_character()) #ou autre type
## col_select = c(ID, YEAR, MONTH, starts_with("VALUE"))

################################################################################

# Gestion des dates
## https://www.stat.berkeley.edu/~s133/dates.html 


## Pour construire le site web

## bookdown::render_book("bs4_book")
## bookdown::render_book("git_book")

################################################################################

# git branch issue_X
# git checkout issue_X

### Faire modifications

# git commit -m ' xxxxx closes #1'  (https://stackoverflow.com/questions/60027222/github-how-can-i-close-the-two-issues-with-commit-message)
#
# Opt : envoi vers github (origin) : git push --set-upstream origin issue_2
#
# Opt : merge local sur main
#
# git checkout main
# git merge issue_x
# git status
# git push
#
# Si problème avec push (stuck après Total,) : git push -u origin main
#

################################################################################

# Snakemake

# Forcer le wrokflow complet :
# snakemake -c1 -F

# Forcer 1 seule rule:
# snakemake -c1 -R nom_rule



################################################################################
# Format de tous les `inline chunk`

# inline_hook <- function(x){
#   
#   # Tout mettre les sorties en gras 
#   # paste0("**",x,"**")
#   
# }
# 
# knit_hooks$set(inline = inline_hook)

################################################################################

# Commande de imagemagick pour rendre le blanc autour du logo transparent

# convert comm_5.png -fuzz 50%  -transparent White x.png

# Pour enlever le blanc autour seulement
# convert x.jpeg -fuzz 15% -bordercolor white -border 1 -fill none -draw "alpha 0,0 floodfill" -shave 1x1 x.png

# convert x.tiff -compress lzw y.tif  --> à valider, pour compresser 

################################################################################ 
################################################################################ 

# Matamo pour analytic
## Fichier `matamo-analytics.html`à changer dans les 3 git_book`, dans le fichier `resume_prog/` et directement dans le fichier `index.RMD` de `homepage``
## Seulement la valeur de ID devrait être à changer pour suivre le guide d'une nouvelle année
