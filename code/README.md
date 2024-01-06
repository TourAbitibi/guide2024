# Dossier CODE

Ce dossier contient les différents fichiers de code permettant de préparer les données pour les différents rapports.

## `_LibsVars.R`

Librairies et variables communes à tous les documents `R`. À importer systématiquement.

## `_import_itineraire.R`

Importation du fichier Excel `Itineraires.xlsx` contenant les détails généraux du Tour et le détails des parcours.

Détails généraux sont dans l'onglet `Details`.

Chacune des étapes a son parcours détaillé.

## `_importExportGPX.R`

Code importe tous les fichiers `.gpx` et les transforme en un seul *shapefile* `.shp`

Première étape à réaliser pour donner *l'extent* des parcours.

Output : le shapefile contenant tous les parcours : "gpx/output/parcours.shp"

## `_elv_parcours.R`

Créer le raster avec les données d'élévation et sauvegarder vers `.tif`.

Longue opération manuelle à faire seulement si les parcours sortent de la région habituelle (*extent*).

Output : le raster de la région complète "rasterElevation/elv_parcours.tif"

## `_importExportElevation.R`


Input: le raster de la région complète "rasterElevation/elv_parcours.tif"

Output :  fichiers csv contenant tous les points d'élévation pour toutes les étapes "elevParcours/elev_parcours.csv"

## `graphique_denivele.R`

Création d'un graphique de type line plot à partir du relevé d'élévation au long du parcours.

Input : 
- "elevParcours/elev_parcours.csv"

Output : 
- Fonctions pour création d'un graphique d'élévation complet ou détails km finaux.



