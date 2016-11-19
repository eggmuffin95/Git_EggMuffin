#!/bin/bash
# Date: 16 Fev 2016
# Version 2.0
# Script de Backup automatisé des instances EC2
# Yann DANIEL - Bayard Presse
# Script correspondant aux volumes des instances taggées en "daily"

export PATH=$PATH:/usr/local/bin/:/usr/bin

# On récupère tous les ID des volumes EBS connectés aux instances taggées en backup "daily"
ec2_volume_ebs_id_list=`aws ec2 describe-instances --region eu-west-1 --filters "Name=tag:backup,Values=daily" --output text --query 'Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId'`

# Pour chaque volume EBS référencé, on récupère la date, on donne une desciption particulière, on lance la création du snapshot
for ec2_volume_ebs_id in $ec2_volume_ebs_id_list
do
	# On récupère l'ID des' instances taggées en backup "daily"
	ec2_volume_instance_id=`aws ec2 describe-volumes --region eu-west-1 --volume-id ${ec2_volume_ebs_id} --output text --query 'Volumes[*].Attachments[*].InstanceId'`
  	# On récupère le nom des instances taggées en backup "daily"
	ec2_volume_instance_name=`aws ec2 describe-instances --region eu-west-1 --instance-ids ${ec2_volume_instance_id} --output text --query 'Reservations[].Instances[].Tags[?Key==\`Name\`].Value'`
	echo $ec2_volume_ebs_id
	echo $ec2_volume_instance_id
	echo $ec2_volume_instance_name
	echo "********"
  echo -n `date +"%D %T"`
  echo -n " Starting $ec2_volume_ebs_id - " 
  aws ec2 create-snapshot --region eu-west-1 --output text --description "Daily - $ec2_volume_instance_name - $ec2_volume_ebs_id" --volume-id "$ec2_volume_ebs_id" --query SnapshotId

	# Pour chaque Volume, on récupère le nombre de Snapshots et on stocke les résultats unitaires dans une variable
	Snapshot_info=/tmp/Snapshot_daily_info.txt
	aws ec2 describe-snapshots --region eu-west-1  --query Snapshots[*].[SnapshotId,VolumeId,Description,StartTime] --output text --filters "Name=status,Values=completed" "Name=volume-id,Values=$ec2_volume_ebs_id" | grep -v "CreateImage" > $Snapshot_info

	# Pour chaque Snapshot_info, on récupère les ID de snapshot et la date
	while read SNAP_INFO
	do
		snapshot_id=`echo $SNAP_INFO | awk '{print $1}'`
		snapshot_date=`echo $SNAP_INFO | awk '{print $NF}' | awk -F"T" '{print $1}'`
		echo $SNAP_INFO
		# On récupère désormais le nombre de jours existants entre la snapshot_date et la date du jour
		DATE=`date +%Y-%m-%d`
		retention_diff=`echo $(($(($(date -d "$DATE" "+%s") - $(date -d "$snapshot_date" "+%s"))) / 86400))`
		echo $retention_diff
		# Et l'on supprime les snapshots qui sont plus vieux que la période de rétention définie
		retention=7
		if [ $retention -lt $retention_diff ];
		then
			aws ec2 delete-snapshot --snapshot-id $snapshot_id --region eu-west-1 --output text > /tmp/deleted-snapshots
			echo DELETING $SNAP_INFO
		fi
	done < $Snapshot_info

done
