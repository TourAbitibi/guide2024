# Instruction pour bloquer l'affichage des résultats avant la course

Pour éviter que :

- Les résultats d'étape
- Les maillots après l'étape
- Les porteurs de maillots

soient affichés avant la course, il faut **modifier le nom du fichier `results/Liste_Coureurs.csv`** hors du fichier à `results/Liste_Coureurs__.csv` .

Cela empêche l'affichage des tableaux dans les pages d'étapes lors de l'utilisation de `code/_importResults.R`


## Résultats

Pour être capable de rouler le calculs des bourses, il faut remplir manuellement :

- ListeAbitibiens.csv : tous les Abitibiens inscrits au Tour de l'Abitibi 
- Maires.csv : résultats des Sprint de Maire (Maires__.csv avant la fin de la semaine pour éviter le calcul avant la fin)
