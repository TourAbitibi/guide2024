# Guide Technique Tour de l'Abitibi 2024

Préparation du guide technique du [Tour de l'Abitibi](https://tourabitibi.com/) 2024.

## Objectifs

- Accès en ligne via un format bookdown
- Création d'un PDF pour impression d'un nombre limité de copies
- Versions en français et en anglais
- Favoriser la collaboration
- Maximiser les automatisations
- Travailler les parcours de course à partir des fichiers bruts (.gpx)
- Pérenniser les opérations
- Préparer un guide de l'organisateur permettant de présenter les procédures, tous les points dangereux et la responsabilité de chacun.

## Guide WEB

Les guides suivants sont disponibles sur le web via https://tourabitibi.github.io/guide2024/

- `index.html` comme page d'acceuil
- dossier `prog`pour partager la programmation préliminaire Tour Abitibi et Tour Relève
- dossiers `EN`et `FR` pour la version en ligne du guide technique - course
- dossier `organisateur`pour la version du guide avec les détails de l'organisation

## Processus manuels

Certains processus manuels sont aussi inclus :

- `code/DocCourse.R`pour suivre les vitesses moyennes et maj des prévisions d'heures de passage en temps réel
- `code/_importResults.R`pour importer les résultats en provenance du logiciel de suivi de RSS Timing
- `code/_exportLignes_Jaune_JauneMoto.R` produire un fichier excel contenant :
  - Les lignes à tracer sur la route
  - Les signaleurs drapeaux jaunes
  - Les motos drapeaux jaunes
