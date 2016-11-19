#!/bin/bash
# Date: 25 Juillet 2016
# Version 1.0
# Script d'envoi et rotation de logs automatisé sur S3 avec prise en charge scénario Auto-Scaling
# Yann DANIEL - Bayard Presse
# Ce script fait appel à des tags qui doivent être renseignés sur l'EC2 afin de composer dynamiquement un path"
# Ce script fait appel des données propres à l'instance EC2 récupérées via le user-data AWS
if [ -z $1 ]; then
	echo "Erreur: aucun fichier transmis... Exiting..."
	exit;
fi

echo 'Starting S3 Log Upload...'
# Perform Rotated Log File Compression
tar -czPf "$1".gz "$1"

# Déclaration des variables

EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"
REGION="eu-west-1"
BUCKET_NAME="bayard-logs"
APP=`aws ec2 describe-instances --region eu-west-1 --instance-ids ${EC2_INSTANCE_ID} --output text --query 'Reservations[].Instances[].Tags[?Key==\`app\`].Value'`
CONTEXT=`aws ec2 describe-instances --region eu-west-1 --instance-ids ${EC2_INSTANCE_ID} --output text --query 'Reservations[].Instances[].Tags[?Key==\`context\`].Value'`
TYPE=`aws ec2 describe-instances --region eu-west-1 --instance-ids ${EC2_INSTANCE_ID} --output text --query 'Reservations[].Instances[].Tags[?Key==\`type\`].Value'`
LOGTYPE=`echo $1 |awk -F'/' '{print $4"-"$5}'`

# Fetch the instance id from the instance
if [ -z $EC2_INSTANCE_ID ]; then
	echo "Erreur: L'ID de l'instance n'a pas pu être trouvé... Exiting..."
	exit;
else

# Envoi des logs sur S3

#/usr/bin/aws s3 --region eu-west-1 cp "$1" s3://$BUCKET_NAME/${APP}/${CONTEXT}/${TYPE}/$(date +%Y)/$(date +%m)/$(date +%d)/$EC2_INSTANCE_ID$1-$(date +%H%M%S).gz
/usr/bin/aws s3 --region $REGION cp "$1" s3://$BUCKET_NAME/${APP}/${CONTEXT}/${TYPE}/$(date +%Y)/$(date +%m)/$(date +%d)/$EC2_INSTANCE_ID-${LOGTYPE}-$(date +%H%M%S).gz

fi

# Removing Rotated Compressed Log File
rm -f "$1".gz
