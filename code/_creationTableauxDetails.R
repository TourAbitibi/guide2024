#!/usr/bin/env Rscript --vanilla

################################################################################
# Création des images des tableau de description détaillé des étapes
#
# Input : fichier Excel "excel/Itineraires.xlsx"
#         _import_itineraire.R
# Output : 
#  - images des tableaux en francais et anglais en format PDF
#  - dans les fichier guide_FR_PDF, guide_EN_PDF / details
#
# ref: https://www.rdocumentation.org/packages/kableExtra/versions/0.6.1/topics/kable_as_image
#
################################################################################

source(here::here("code","/_import_itineraire.R"))

# Librairies et here chargées dans le fichier précédent

################################################################################

# Définir les étapes selon STD, CLMI ou SOMMET
etapesStd <- c(1,2,6,7)
etapeRouteDemi <- 4
etapeCLMI <- 3
etapeSOMMET <- 5
etapeCircuitUrbain <- 6  # 20240106 : TODO : modifier le texte, circuit urbain n'a jamais été utilisé. SI REQUIS
  
################################################################################
################################################################################


ecrire_tableau_STD <- function(Etape, lang){

  tableau_Descrip_Etape(Etape, lang) %>% save_kable(here(glue("guide_{lang}_PDF"), "details"  , glue("tableau_{Etape}.pdf")))

}

# Produire les tableaux STD - FR et EN
walk(etapesStd, ~ecrire_tableau_STD(.x, "FR"))
walk(etapesStd, ~ecrire_tableau_STD(.x, "EN"))



# Produire le tableau pour le CLMI - FR et EN

ecrire_tableau_CLMI <- function(Etape, lang){
  
  tableau_Descrip_BASE(Etape, lang) %>% save_kable(here(glue("guide_{lang}_PDF"), "details"  , glue("tableau_{Etape}.pdf")))
  
}

ecrire_tableau_CLMI(etapeCLMI, "FR")
ecrire_tableau_CLMI(etapeCLMI, "EN")

# Produire le tableau pour la demi-étape - FR et EN

ecrire_tableau_DemiEtape <- function(Etape, lang){
  
  tableau_Descrip_Etape_Demi(Etape, lang) %>% save_kable(here(glue("guide_{lang}_PDF"), "details"  , glue("tableau_{Etape}.pdf")))
  
}

ecrire_tableau_DemiEtape(etapeRouteDemi, "FR")
ecrire_tableau_DemiEtape(etapeRouteDemi, "EN")


# Produire le tableau pour l'arrivée au sommet - FR et EN

ecrire_tableau_SOMMET <- function(Etape, lang){
  
  tableau_Descrip_Etape_Sommet(Etape, lang) %>% save_kable(here(glue("guide_{lang}_PDF"), "details"  , glue("tableau_{Etape}.pdf")))
  
}

# ecrire_tableau_SOMMET(etapeSOMMET, "FR")
# ecrire_tableau_SOMMET(etapeSOMMET, "EN")

