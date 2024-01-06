#!/bin/usr/env sh

# NOTE 2024 : encore utilisé ???

#
# Script pour exporter git_book_organisateur produit localement vers NAS
#

# Si les fichiers existent déjà sur le NAS
if ls /Volumes/web/guide/organisateur/* 1> /dev/null 2>&1; 
then
  echo "~~ fichiers existants à effacer sur le NAS ~~ \n" &
rm -rf ~/Volumes/web/guide/organisateur
fi

## Commande pour copier le contenu du book vers NAS
echo "\n\n~~ Copie vers le NAS pour affichage web ~~ \n" &&

mkdir -p /Volumes/web/guide/organisateur &&cp -R  git_book_organisateur/_book/* /Volumes/web/guide/organisateur

## Copier les images -- pas nécessaire, déjà fait dans le script précédent

echo "~~ Fin de la copie vers le NAS ~~ \n"

echo "~~ Ménage du dossier temporaire ~~\n"

rm -rf git_book_organisateur/guide_organisateur_files

echo Guide disponible au : https://home.brunogauthier.net/guide/organisateur 