#!/bin/bash

for i in `aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:shutdownAtNight,Values=true" --output text --query 'Reservations[*].Instances[*].InstanceId'`
do

  echo -n `date +"%D %T"`
  echo -n " Starting $i - "
  aws ec2 describe-instances --region eu-west-1 --instance-ids $i --output text --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value'
  aws ec2 start-instances --region eu-west-1 --output text --instance-ids $i

done
