#########################################################################################
# Page programmation                                                                    #
#                                                                                       #
# Input : Itinéraire.xlsx                                                               #
# Output : 2 tibles (FR et EN) contenant les données de programmation                   #
#########################################################################################

# Gestion avec here
here::i_am("guide2024.Rproj")

# Appel des librairies et variables partagées
source(here::here("code","_LibsVars.R"))

# Dates
source(here("code", "_Dates.R"))

# Pour accès aux données du fichier excel Itineraires.xlsx
source(here("code","_import_itineraire.R"))


df <- iti_etape$Details

dates_prog <- str_replace(dates_FR$jsem_jour_mois, ", ", "<br>")


#########################################################################################


# Création du tibble Français #

# Ajout des lignes une à une

# Lundi 
dff <- tibble(
  date =  glue('{dates_prog[2]}'),
  presente  =  glue('<img src="../img/logo/comm_0.png" width="100">'),
  epreuve =  glue('Présentation des équipes<br/>Challenge Sprint Abitibi<br/>'), 
  dep = glue("<strong>xxh30</strong><br/><br/><strong>17h30</strong><br/>Val-d'Or , Hôtel de Ville"),
  arr = glue("<strong>xxh</strong><br/><br/><strong>19h</strong><br/>Val-d'Or , Hôtel de Ville")
)

# Mardi 
dff <- tibble(
  date =  glue('{dates_prog[3]}<br/><br/><strong>Étape 1</strong>'),
  presente  =  glue('<img src="../img/logo/comm_1.png" width="100">'),
  epreuve =  glue('<strong>Route</strong><br/>{df$VilleDep[1]} - {df$VilleArr[1]}<br/>{df$Via[1]}<br/>Distance : {df$Descr_km[1]}<br/>({df$KM_Neutres[1]} km neutralisés au départ)'), 
  dep = glue('<strong>{df$time_depart[1]}</strong><br/>{df$VilleDep[1]}, {df$LieuDepFR[1]}'),
  arr = glue('Entrée en ville : <br/><strong>{df$HeureEntreeVille[1]}</strong> <br/>Arrivée finale : <br/><strong>{df$time_arrivee[1]}</strong><br/>{df$VilleArr[1]}, {df$LieuArrFR[1]}')
  
) %>% 
  bind_rows(dff,.)


# Mercredi 
dff <- tibble(
  date =  glue('{dates_prog[4]}<br/><br/><strong>Étape 2</strong>'),
  presente  =  glue('<img src="../img/logo/comm_2.png" width="200">'),
  epreuve =  glue('<strong>Route</strong><br/>{df$VilleDep[2]} - {df$VilleArr[2]}<br/>{df$Via[2]}<br/>Distance : {df$Descr_km[2]}<br/>({df$KM_Neutres[2]} km neutralisés au départ)'), 
  dep = glue('<strong>{df$time_depart[2]}</strong><br/>{df$VilleDep[2]}, {df$LieuDepFR[2]}'),
  arr = glue('<strong>{df$time_arrivee[2]}</strong><br/>{df$VilleArr[2]}, {df$LieuArrFR[2]}')
) %>% 
  bind_rows(dff,.)


# Jeudi AM 
dff <- tibble(
  date =  glue('{dates_prog[5]} (AM)<br/><br/><strong>Étape 3 (demi-étape)</strong>'),
  presente  =  glue('<img src="../img/logo/comm_3.png" width="100">'),
  epreuve =  glue('<strong>Contre-la-montre Individuel</strong><br/>{df$VilleDep[3]} - {df$Via[3]} - {df$VilleArr[3]}<br/>Distance : {df$Descr_km[3]}'), 
  dep = glue('Premier départ : <strong>{df$time_depart[3]}</strong><br/>Dernier départ : <strong>{df$DerDep[3]}</strong><br/>{df$VilleDep[3]}, {df$LieuDepFR[3]}'),
  arr = glue('Première arrivée : <strong>{df$time_arrivee[3]}</strong><br/>Dernière arrivée : <strong>{df$DerArr[3]}</strong><br/>{df$VilleArr[3]}, {df$LieuArrFR[3]}')
) %>% 
  bind_rows(dff,.)


# Jeudi PM 
dff <- tibble(
  date =  glue('{dates_prog[5]} (PM)<br/><br/><strong>Étape 4 (demi-étape)</strong>'),
  presente  =  glue('<img src="../img/logo/comm_4.png" width="100">'),
  epreuve =  glue('<strong>Route</strong><br/>{df$VilleDep[4]} - {df$Via[4]} - {df$VilleArr[4]}<br/>Distance : {df$Descr_km[4]}<br/>({df$KM_Neutres[4]} km neutralisés au départ)'), 
  dep = glue('<strong>{df$time_depart[4]}</strong><br/>{df$VilleDep[4]}, {df$LieuDepFR[4]}'),
  arr = glue('<strong>{df$time_arrivee[4]}</strong><br/>{df$VilleArr[4]}, {df$LieuArrFR[4]}')
) %>% 
  bind_rows(dff,.)


# Vendredi 
dff <- tibble(
  date =  glue('{dates_prog[6]}<br/><br/><strong>Étape 5</strong>'),
  presente  =  glue('<img src="../img/logo/comm_5.png" width="100">'),
  epreuve =  glue('<strong>Route</strong><br/>{df$VilleDep[5]} &#8634; {df$VilleArr[5]}<br/> {df$Via[5]}<br/>Distance : {df$Descr_km[5]}<br/>({df$KM_Neutres[5]} km neutralisés au départ)'), 
  dep = glue('<strong>{df$time_depart[5]}</strong><br/>{df$VilleDep[5]}, {df$LieuDepFR[5]}'),
  arr = glue('<strong>{df$time_arrivee[5]}</strong><br/>{df$VilleArr[5]}, {df$LieuArrFR[5]}')
) %>% 
  bind_rows(dff,.)


# Samedi
dff <- tibble(
  date =  glue('{dates_prog[7]}<br/><br/><strong>Étape 6</strong>'),
  presente  =  glue('<img src="../img/logo/comm_6.png" width="100">'),
  epreuve =  glue('<strong>Circuit Urbain</strong><br/>{df$VilleDep[6]} &#8635; {df$VilleArr[6]}<br/>{df$Via[6]} <br/>Distance : {df$Descr_km[6]}'), 
  dep = glue('<strong>{df$time_depart[6]}</strong><br/>{df$VilleDep[6]}, {df$LieuDepFR[6]}'),
  arr = glue('<strong>{df$time_arrivee[6]}</strong><br/>{df$VilleArr[6]}, {df$LieuArrFR[6]}')
) %>% 
  bind_rows(dff,.)

# Dimanche
dff <- tibble(
  date =  glue('{dates_prog[8]}<br/><br/><strong>Étape 7</strong>'),
  presente  =  glue('<img src="../img/logo/comm_7.png" width="100">'),
  epreuve =  glue('<strong>Route</strong><br/>{df$VilleDep[7]} - {df$VilleArr[7]}<br/>{df$Via[7]}<br/>Distance : {df$Descr_km[7]}<br/>({df$KM_Neutres[7]} km neutralisés au départ)'), 
  dep = glue('<strong>{df$time_depart[7]}</strong><br/>{df$VilleDep[7]}, {df$LieuDepFR[7]}'),
  arr = glue('Entrée en ville : <br/><strong>{df$HeureEntreeVille[7]}</strong> <br/>Arrivée finale : <br/><strong>{df$time_arrivee[7]}</strong><br/>{df$VilleArr[7]}, {df$LieuArrFR[7]}')
) %>% 
  bind_rows(dff,.)



##################################################################################################################################################################################

##################################################################################################################################################################################

# Création du tibble Anglais #

dates_prog <- str_replace(dates_EN$jsem_jour_mois, ", ", "<br>")


# Lundi 
dfe <- tibble(
  date =  glue('{dates_prog[2]}'),
  presente  =  glue('<img src="../img/logo/comm_0.png" width="100">'),
  epreuve =  glue('Team Presentation<br/>Challenge Sprint Abitibi<br/>'), 
  dep = glue("<strong>16h30</strong><br/><br/><strong>17h30</strong><br/>Val-d'Or , City Hall"),
  arr = glue("<strong>17h</strong><br/><br/><strong>19h</strong><br/>Val-d'Or , City Hall")
)

# Mardi 
dfe <- tibble(
  date =  glue('{dates_prog[3]}<br/><br/><strong>Stage 1</strong>'),
  presente  =  glue('<img src="../img/logo/comm_1.png" width="100">'),
  epreuve =  glue('<strong>Road race</strong><br/>{df$VilleDep[1]} - {df$VilleArr[1]}<br/>{df$Via[1]}<br/>Distance : {df$Descr_km[1]}<br/>({df$KM_Neutres[1]} km controlled start)'), 
  dep = glue('<strong>{df$time_depart[1]}</strong><br/>{df$VilleDep[1]}, {df$LieuDepEN[1]}'),
  arr = glue('Circuit arrival : <br/><strong>{df$HeureEntreeVille[1]}</strong> <br/>Finish : <br/><strong>{df$time_arrivee[1]}</strong><br/>{df$VilleArr[1]}, {df$LieuArrEN[1]}')
  ) %>% 
  bind_rows(dfe,.)


# Mercredi 
dfe <- tibble(
  date =  glue('{dates_prog[4]}<br/><br/><strong>Stage 2</strong>'),
  presente  =  glue('<img src="../img/logo/comm_2.png" width="200">'),
  epreuve =  glue('<strong>Road race</strong><br/>{df$VilleDep[2]} - {df$VilleArr[2]}<br/>{df$Via[2]}<br/>Distance : {df$Descr_km[2]}<br/>({df$KM_Neutres[2]} km controlled start)'), 
  dep = glue('<strong>{df$time_depart[2]}</strong><br/>{df$VilleDep[2]}, {df$LieuDepEN[2]}'),
  arr = glue('<strong>{df$time_arrivee[2]}</strong><br/>{df$VilleArr[2]}, {df$LieuArrEN[2]}')
  ) %>% 
  bind_rows(dfe,.)


# Jeudi AM 
dfe <- tibble(
  date =  glue('{dates_prog[5]} (AM)<br/><br/><strong>Stage 3 (half-stage)</strong>'),
  presente  =  glue('<img src="../img/logo/comm_3.png" width="100">'),
  epreuve =  glue('Individual Time Trial</strong><br/>{df$VilleDep[3]} - {df$Via[3]} - {df$VilleArr[3]}<br/>Distance : {df$Descr_km[3]}'), 
  dep = glue('First start : <br/><strong>{df$time_depart[3]}</strong><br/>First arrival : <br/><strong>{df$DerDep[3]}</strong><br/>{df$VilleDep[3]}, {df$LieuDepEN[3]}'),
  arr = glue('Last start : <strong>{df$time_arrivee[3]}</strong><br/>Last arrival : <strong>{df$DerArr[3]}</strong><br/>{df$VilleArr[3]}, {df$LieuArrEN[3]}')
) %>% 
  bind_rows(dfe,.)


# Jeudi PM 
dfe <- tibble(
  date =  glue('{dates_prog[5]} (PM)<br/><br/><strong>Stage 4 (half-stage)</strong>'),
  presente  =  glue('<img src="../img/logo/comm_4.png" width="100">'),
  epreuve =  glue('Road race</strong><br/>{df$VilleDep[4]} - {df$Via[4]} - {df$VilleArr[4]}<br/>Distance : {df$Descr_km[4]}<br/>({df$KM_Neutres[4]} km controlled start)'), 
  dep = glue('<strong>{df$time_depart[4]}</strong><br/>{df$VilleDep[4]}, {df$LieuDepEN[4]}'),
  arr = glue('<strong>{df$time_arrivee[4]}</strong><br/>{df$VilleArr[4]}, {df$LieuArrEN[4]}')
) %>% 
  bind_rows(dfe,.)


# Vendredi 
dfe <- tibble(
  date =  glue('{dates_prog[6]}<br/><br/><strong>Stage 5</strong>'),
  presente  =  glue('<img src="../img/logo/comm_5.png" width="100">'),
  epreuve =  glue('Road race</strong><br/>{df$VilleDep[5]} &#8634; {df$VilleArr[5]}<br/> {df$Via[5]}<br/>Distance : {df$Descr_km[5]}<br/>({df$KM_Neutres[5]} km controlled start)'), 
  dep = glue('<strong>{df$time_depart[5]}</strong><br/>{df$VilleDep[5]},<br/>{df$LieuDepEN[5]}'),
  arr = glue('<strong>{df$time_arrivee[5]}</strong><br/>{df$VilleArr[5]},<br/>{df$LieuArrEN[5]}')
) %>% 
  bind_rows(dfe,.)


# Samedi
dfe <- tibble(
  date =  glue('{dates_prog[7]}<br/><br/><strong>Stage 6</strong>'),
  presente  =  glue('<img src="../img/logo/comm_6.png" width="100">'),
  epreuve =  glue('Urban Circuit</strong><br/>{df$VilleDep[6]} &#8635; {df$VilleArr[6]}<br/>{df$Via[6]}<br/>Distance : {df$Descr_km[6]}'), 
  dep = glue('<strong>{df$time_depart[6]}</strong><br/>{df$VilleDep[6]},<br/>{df$LieuDepEN[6]}'),
  arr = glue('<strong>{df$time_arrivee[6]}</strong><br/>{df$VilleArr[6]},<br/>{df$LieuArrEN[6]}')
) %>% 
  bind_rows(dfe,.)

# Dimanche
dfe <- tibble(
  date =  glue('{dates_prog[8]}<br/><br/><strong>Stage 7</strong>'),
  presente  =  glue('<img src="../img/logo/comm_7.png" width="100">'),
  epreuve =  glue('Road race</strong><br/>{df$VilleDep[7]} - {df$VilleArr[7]}<br/>{df$Via[7]}<br/>Distance : {df$Descr_km[7]}<br/>({df$KM_Neutres[7]} km controlled start)'), 
  dep = glue('<strong>{df$time_depart[7]}</strong><br/>{df$VilleDep[7]}, {df$LieuDepEN[7]}'),
  arr = glue('Circuit arrival : <br/><strong>{df$HeureEntreeVille[7]}</strong> <br/>Finish : <br/><strong>{df$time_arrivee[7]}</strong><br/>{df$VilleArr[7]}, {df$LieuArrEN[7]}')
) %>% 
  bind_rows(dfe,.)