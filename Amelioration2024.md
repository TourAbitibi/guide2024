# Améliorations site web pour 2024

## Structure dossier

- Changer la structure du site web pour qu'il soit entièrement dans un fichier `guide2024`plutôt qu'à `root`. Par la suite, on peut bâtir la page à partir de ce dossier directement.
- Cela facilitera le rsync local et conservera tout ce qui est site web au même endroit.
- Facilitera le déploiement github-pages ? Pas besoin d'essayer de compiler tout ?

## Déploiement github

- Faire le deploy sur une branche particulière ? Pour éviter de faire la mise à jour à tout push ?

- Voir fichier SCI1402 : `static.yaml` pour modification vers une github page
  - déploiement static (pas de jekyll qui prend du temps)
  - potentiel de choisir le fichier (`with path:`), ce qui permet d'éviter d'être à la racine complètement (répond au besoin plus haut)

```yaml
# Simple workflow for deploying static content to GitHub Pages
name: Deploy static content to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["main"]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  # Single deploy job since we're just deploying
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Setup Pages
        uses: actions/configure-pages@v3
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          # Upload entire repository
          path: docs/_build/html
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

## Adresse

- Trouver le moyen de faire une redirection `cname`fonctionnelle avec https://guide.tourabitibi.com
