# Dossier : gpx

## input

Fichiers `.gpx` nécessaires à la création des parcours.

Le nom du gpx enregistré doit être : 
- `Course_1.gpx` pour les gpx de la course (KOM, sprint,...)
- `Signalisation_1.gpx` pour les gpx avec la signalisation (terre-plein, virages, ...)
- `Signalisation_1.csv` pour les cuesheet de signalisation en `.csv`, le lien le *gpx* et le *csv*étant le nom des points : sign_01, sign_02, ...

~~Le `name` des étapes vient du nom d'enregistrement sur [Ride with GPS](https://ridewithgps.com).~~

Le `name` des étapes et corriger et vient du fichier excel maître `Itineraires.xlsx`.

## output

*Shapefiles* `.shp` travaillée et prêts à être utilisés vers sites tel que Google Earth.

- `parcours.shp` contient les tracés de base;
- `points_parcours.shp` contient les POI de course (départ réel, KOM, bonus, $$)
- `points_signalisation.shp` contient les POI de signalisation (terre-plein, danger, signaleurs,...) pour le guide d'organisation

Pour importer : `parcours <- st_read("gpx/output/parcours.shp")`
