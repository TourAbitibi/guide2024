#!/usr/bin/env Rscript --vanilla

################################################################################

# File : script/render_book.R

# Obj : automatiser la création des différents guides
#       peut être appelé à partir d'un script ou au terminal
#         ---> `Rscript render_book.R`
# 
# Ref Snakemake : 
# https://stackoverflow.com/questions/68620638/how-to-execute-r-inside-snakemake
#
################################################################################
#!/usr/bin/env Rscript

library(argparse)

parser <- ArgumentParser(description= 'Envoyer des paramètres dans R')

parser$add_argument('--path', '-p', help= 'Path to book to render')


xargs<- parser$parse_args()


## Créer site web Guide Technique Français
bookdown::render_book(xargs$path)

#bookdown::render_book("git_book")

