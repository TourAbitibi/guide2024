#!/bin/usr/env sh

# NOTE 2024 : encore utilisé ???


#
# Script pour exporter git_book produit localement vers NAS
#

# Si les fichiers FR existent déjà sur le NAS
if ls /Volumes/web/guide/FR/* 1> /dev/null 2>&1; 
then
  echo "~~ fichiers existants FR à effacer sur le NAS ~~ \n" &
rm -rf ~/Volumes/web/guide/FR
fi

# Si les fichiers EN existent déjà sur le NAS
if ls /Volumes/web/guide/EN/* 1> /dev/null 2>&1; 
then
  echo "~~ fichiers existants EN à effacer sur le NAS ~~ \n" &
rm -rf ~/Volumes/web/guide/EN
fi

## Commande pour copier le contenu du book vers NAS
echo "~~ Copie vers le NAS pour affichage web ~~ \n" &&

mkdir -p /Volumes/web/guide/FR &&cp -R  git_book/_book/* /Volumes/web/guide/FR
mkdir -p /Volumes/web/guide/EN &&cp -R  git_book_EN/_book/* /Volumes/web/guide/EN

## Copier les images
mkdir -p /Volumes/web/guide/img && cp -R  img/* /Volumes/web/guide/img

echo "~~ Fin de la copie vers le NAS ~~ \n"

echo "~~ Ménage du dossier temporaire ~~\n"

# Effacer guide2023_files si existe encore dans 'git_book'
rm -rf git_book/guide2023_files
rm -rf git_book_EN/guide2023_files


echo "Guide disponible au : https://home.brunogauthier.net/2024/FR et https://home.brunogauthier.net/2024/EN \n \n"