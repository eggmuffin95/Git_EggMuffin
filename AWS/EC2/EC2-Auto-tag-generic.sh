#!/bin/bash

# Date: 24 Fev 2016
# Version 1.0
# Script d'ajout généralisé de Tags
# Yann DANIEL - Bayard Presse

# Ce script a pour but de pouvoir généraliser la création d'un Tag et de fixer sa valeur en fonction de critères vérifiés

# Ask user for Tag name
echo -n "Taper le nom souhaité pour l'intitulé du Tag et [ENTER] :"
read tag

# Ask user for Tag Value
echo -n "Taper le nom souhaité pour la valeur du Tag et [ENTER] :"
read value

# Ask user for the Tag destination
PS3="Sélectionner la destination du Tag :"

# Allow user to chose between 6 choices
options=("Instances" "AMIs" "Volumes" "Snapshots" "Network Interfaces" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Instances")
      echo "Vous avez choisi de Tagger des Instances"
      # La première phase consiste juste à créer le Tag sur la section Instances
      aws ec2 create-tags 
      # L'idée est de tagger les instances en fonction d'un tag existant
      # Par exemple, on récupère toutes les instances pour lesquelles le Tag App vaut APP1 et l'on peut
      ;;
    "AMIs")
      echo "Vous avez choisi de Tagger des AMIs"
      ;;
    "Volumes")
      echo "Vous avez choisi de Tagger des Volumes"
      ;;
    "Snapshots")
      echo "Vous avez choisi de Tagger des Snapshots"
      ;;
    "Network Interfaces")
      echo "Vous avez choisi de Tagger des Network Interfaces"
      ;;
    "Quit")
      echo "A bientôt !"
      break
      ;;
    *) echo invalid option;;
  esac
