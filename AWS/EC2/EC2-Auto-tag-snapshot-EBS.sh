#!/bin/bash

# Date: 24 Fev 2016
# Version 1.0
# Script d'ajout de Tag automatique aux snapshots EBS relatif à la quantité maximale de snapshots à conserver
# Pour le moment, nn fixe arbitrairement cette quantité à 3 pour tous les snapshots
# Ce script peut aisément être ajouté en complément de scripts existants et peut également être adapté pour attribuer des Tags différents en fonction de critères évalués
# Yann DANIEL - Bayard Presse

# On liste d'abord l'intégralité des snapshots disponibles
snapshot_list=`aws ec2 describe-snapshots --region eu-west-1 --query Snapshots[*].[SnapshotId] --output text`

# On créé maintenant pour chacun le Tag "Retention" de Valeur "3"
for snapshot in $snapshot_list
do
aws ec2 create-tags --region eu-west-1 --output=text --resources "${snapshot}" --tags Key=Retention,Value=3

done


# A faire tourner après l'éxécution des snapshots
