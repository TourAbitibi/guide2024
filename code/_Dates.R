#!/usr/bin/env Rscript --vanilla

################################################################################
#
# _Dates.R
#
# Lecture du ficher excel "itinéraire" ,
# Préparation des dates
#
# Input : fichier Excel "excel/Itineraires.xlsx"
# Output : 
#  - dataframe des dates formatées comme texte
#
# Ref: https://www.ibm.com/docs/en/cmofz/10.1.0?topic=SSQHWE_10.1.0/com.ibm.ondemand.mp.doc/arsa0257.htm
#
################################################################################

# Partie française
Sys.setlocale("LC_TIME", locale = "fr_CA.UTF-8")

# Date du mardi de la première étape comme base de référence 
Mardi_etape1<- read_excel(here("excel", "Itineraires.xlsx"), sheet = "Details") %>% 
  slice(1) %>%  pull(Date) 


# df dates en français

dates_FR <- tibble(
  code = c("Dim_Av", "Lun_Av", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim", "Lun_Ap"),
  a_m_j = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%Y-%m-%d")) %>% unlist(),
  jour_mois = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%d %B")) %>% unlist(),
  jour_mois_an = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%d %B %Y")) %>% unlist(), 
  jsem_jour_mois = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%A, %d %B")) %>% unlist(),
  jsem_jour_mois_an = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%A, %d %B %Y")) %>% unlist()
) %>% 
  mutate(
    jour_mois = str_replace(jour_mois, "^0", ""),
    jour_mois_an = str_replace(jour_mois_an, "^0", ""),
    jsem_jour_mois = str_replace(jsem_jour_mois, ", 0", ", "),
    jsem_jour_mois_an = str_replace(jsem_jour_mois_an, ", 0", ", ")
  )


# Partie anglaise

Sys.setlocale("LC_TIME", locale = "en_US.UTF-8")

dates_EN <- tibble(
  code = c("Dim_Av", "Lun_Av", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim", "Lun_Ap"),
  a_m_j = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%Y-%m-%d")) %>% unlist(),
  jour_mois = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%B, %dth")) %>% unlist(),
  jour_mois_an = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%B %dth, %Y")) %>% unlist(),
  jsem_jour_mois = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%A, %B %dth")) %>% unlist(),
  jsem_jour_mois_an = map(.x = -2:6  , ~ format(Mardi_etape1 + ddays(.x) ,format = "%A, %B %dth, %Y")) %>% unlist()
)%>% 
  mutate(
    jour_mois = str_replace(jour_mois, ", 0", ", "),
    jour_mois_an = str_replace(jour_mois_an, " 0", ", "),
    jsem_jour_mois = str_replace(jsem_jour_mois, " 0", ", "),
    jsem_jour_mois_an = str_replace(jsem_jour_mois_an, " 0", ", ")
  )

# Retour au local Français
Sys.setlocale("LC_TIME", locale = "fr_CA.UTF-8")
