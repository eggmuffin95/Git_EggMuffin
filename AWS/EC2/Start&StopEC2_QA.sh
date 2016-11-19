#!/bin/bash
# Date: 30 Août 2016
# Version 1.0
# Script de Start&Stop manuel des instances EC2 API de QA
# Yann DANIEL - Bayard Presse
# Script correspondant aux instances taggées en "qa"

export PATH=$PATH:/usr/local/bin/:/usr/bin

instances=`aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:app,Values=API" "Name=tag:context,Values=qa" --output text --query 'Reservations[*].Instances[*].InstanceId'`

#Déclaration des contextes

start ()
{
       	echo "Starting Instances..."
       	for i in $instances
       	do
       		echo -n "Starting $i"
       		aws ec2 start-instances --region eu-west-1 --output text --instance-ids $i
       	done
}

stop ()
{
       	echo "Stopping Instances..."
       	for i in $instances
       	do
       		echo -n "Stopping $i"
       		aws ec2 stop-instances --region eu-west-1 --output text --instance-ids $i
       	done
}

display_usage ()
{
        echo "The start or stop argument is mandatory";
        echo -e "\nUsage:\n\t$0 <start> or <stop>"
}


if [ -z "$1" ]
        then
                display_usage
                exit;
fi

if [ "$1" == "start" ];
       	then
       		start
       		exit;
fi

if [ "$1" == "stop" ];
       	then
       		stop
       		exit;
fi
