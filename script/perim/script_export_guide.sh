#!/bin/usr/env sh

# NOTE 2024 : encore utilisé ???

#
# Script pour exporter git_book produit localement vers NAS
#
# Pourrait être modifié pour prendre arguements (quand j'aurai un FR et un EN à faire)
#

# Paramètres à passer :
path=$1 # Nom du dossier contenant le book, selon la langue
lang=$2 # Langue, pour envoyer vers le bon sous-dossier


# Si les fichiers existent déjà sur le NAS
if ls /Volumes/web/guide/$lang/* 1> /dev/null 2>&1; 
then
  echo "~~ fichiers existants à effacer sur le NAS ~~ \n" &
rm -rf ~/Volumes/web/guide/$lang
fi

## Commande pour copier le contenu du book vers NAS
echo "~~ Copie vers le NAS pour affichage web ~~ \n" &&

mkdir -p /Volumes/web/guide/$lang &&cp -R  $path/_book/* /Volumes/web/guide/$lang

## Copier les images

mkdir -p /Volumes/web/guide/img && cp -R  img/* /Volumes/web/guide/img

echo "~~ Fin de la copie vers le NAS ~~ \n"

echo "~~ Ménage du dossier temporaire ~~\n"

# Effacer guide2023_files si existe encore dans 'git_book'
#if ls $path/ | grep guide2023_files 1> /dev/null 2>&1;
#then
rm -rf $path/guide2023_files
#fi

echo Guide disponible au : https://home.brunogauthier.net/guide/$lang 