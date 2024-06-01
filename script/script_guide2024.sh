#!/bin/usr/env sh

## Script d'ouverture du dossier
## à partir du mac de Bruno

conda activate base &&
	cd ~/Documents/guide2024/ >/dev/null &&
	echo ~~fetch~~ &&
	git fetch &&
	echo ~~status~~ &&
	git status &&
	echo "\n~~ faire git pull si requis ~~" &&
	open .
