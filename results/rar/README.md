# Fichiers Résultats

Fichier provenant de l'export du logiciel de Sylvain Richard.

Le fichier `code/_importResults.R` a été préparé très spécifiquement pour cette sortie précise et ne fonctionnera pas si les fichiers proviennent d'autres sources. 

Seulement les fichiers `.csv` sont utilisés, en enlevant à chaque fois de nombreuses lignes préliminaires non-tabulaires. 

## Input

`StageRace.rar` en prenant soin de s'assurer qu'il n'y a pas d'espace entre Stage et Race. Document contient les résultats d'étapes à mesure qu'ils sont jugées. 

Exécuter tout le code `R` pour dezipper le fichier `.rar` et extraire les derniers résultats de course vers un format standardisé en `.csv`.

## Output

```
results
├── Equipe_General_results.csv
├── Equipes_Etapes_results.csv
├── Etapes_results.csv
├── General_results.csv
├── Jeune_General_results.csv
├── Jeunes_Etapes_results.csv
├── KOM_General_results.csv
├── Liste_Coureurs.csv
├── Liste_Equipes.csv
├── Points_Genral_results.csv
├── rar
└── unrar
```

